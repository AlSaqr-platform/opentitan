import os
import subprocess
import concurrent.futures
import time
import glob
import argparse

# --- Configuration ---

# 1. Base test lists
COMPILE_FOLDERS = [
    "sw/tests/generic_test", "sw/tests/regression_tests/hello",
    "sw/tests/regression_tests/opentitan-cluster/addressability",
    "sw/tests/regression_tests/opentitan-cluster/idma_test",
    "sw/tests/regression_tests/opentitan-cluster/mbox_test",
    "sw/tests/regression_tests/parallel_bare_tests/conv16",
    "sw/tests/regression_tests/parallel_bare_tests/parMatrixMul8",
    "sw/tests/regression_tests/parallel_bare_tests/parMatrixMul16",
    "sw/tests/regression_tests/parallel_bare_tests/parMatrixMul32",
    "sw/tests/regression_tests/idma_tests/idma_multi_core",
    "sw/tests/regression_tests/idma_tests/idma_multi_core_2d",
    "sw/tests/regression_tests/idma_tests/idma_multi_core_3d"
]
RUN_FOLDERS = [
    "sw/tests/regression_tests/hello",
    "sw/tests/regression_tests/opentitan-cluster/addressability",
    "sw/tests/regression_tests/opentitan-cluster/idma_test",
    "sw/tests/regression_tests/opentitan-cluster/mbox_test",
    "sw/tests/regression_tests/parallel_bare_tests/conv16",
    "sw/tests/regression_tests/parallel_bare_tests/parMatrixMul8",
    "sw/tests/regression_tests/parallel_bare_tests/parMatrixMul16",
    "sw/tests/regression_tests/parallel_bare_tests/parMatrixMul32",
    "sw/tests/regression_tests/idma_tests/idma_multi_core",
    "sw/tests/regression_tests/idma_tests/idma_multi_core_2d",
    "sw/tests/regression_tests/idma_tests/idma_multi_core_3d"
]

# 2. Generic Command to compile SW/Test applications.
COMPILE_COMMAND = "make clean all"

# 3. Command Templates based on simulation type
RUN_COMMAND_MAP = {
    "rtl": "make sim_rtl_tech_mem SRAM=sw/tests/generic_test/generic_test.elf cl-bin={}/build/test/test",
    "gate": "make sim_gls_run SRAM=sw/tests/generic_test/generic_test.elf cl-bin={}/build/test/test"
}
DEFAULT_SIMULATION_TYPE = "rtl" # Renamed from DEFAULT_NETLIST_TYPE

# 4. Tests that need to be run 3 TIMES (These are the last 3 entries in RUN_FOLDERS)
RUN_TRIPLE_TESTS = [
    "sw/tests/regression_tests/idma_tests/idma_multi_core",
    "sw/tests/regression_tests/idma_tests/idma_multi_core_2d",
    "sw/tests/regression_tests/idma_tests/idma_multi_core_3d"
]

# 5. Definitions for the three unique parametric runs
PARAM_CONFIGS = {
    "_PARAM_A": " QUICK_MODE=1",
    "_PARAM_B": " MULTI_CORE_S=1",
    "_PARAM_C": " MULTI_CORE_P=1"
}

# 6. Design Compilation Commands (Run once from TOP_DIR)
# NOTE: Modify these commands if your targets for the specific design builds are different.
RTL_BUILD_COMMAND = "make build_tech_mem"
GATE_BUILD_COMMAND = "make sim_gls_compile"

# --- Global Context ---
TOP_DIR = os.getcwd()
COMPILATION_SUCCESS = True
RUN_COMMAND_TEMPLATE = ""
LOG_FILE_PATH = "test_run.log" # New global constant for log file

# --- Argument Parsing Function ---

def parse_arguments():
    """Defines and parses command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Run local compilation and global simulation tests in sequence.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        '--sim',
        type=str,
        default=DEFAULT_SIMULATION_TYPE, # Use new constant name
        choices=RUN_COMMAND_MAP.keys(),
        help=f'Selects the simulation type (e.g., RTL or Gate-Level). Default is "{DEFAULT_SIMULATION_TYPE}".\nChoices: {list(RUN_COMMAND_MAP.keys())}' # Updated help text
    )
    return parser.parse_args()


# --- Utility Functions ---

def execute_command(command, directory):
    """Utility function to execute a shell command and log its output."""
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    full_path = os.path.abspath(directory)

    # 1. Log command execution attempt
    with open(LOG_FILE_PATH, "a") as f:
        f.write(f"\n==================================\n")
        f.write(f"[{timestamp}] --- EXECUTING ---\n")
        f.write(f"[CWD] {full_path}\n")
        f.write(f"[CMD] {command}\n")

    # 2. Execute command
    try:
        result = subprocess.run(
            command,
            shell=True,
            check=True,
            cwd=full_path,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True
        )

        # 3. Log success
        with open(LOG_FILE_PATH, "a") as f:
            f.write(f"[{timestamp}] --- SUCCESS ---\n")
            f.write(f"[CWD] {directory} finished successfully.\n")
            f.write(f"[STDOUT (Excerpt)]\n{result.stdout[:500]}...\n" if result.stdout else "[STDOUT] (No output)\n")

        return True

    # 4. Log subprocess failure (CalledProcessError)
    except subprocess.CalledProcessError as e:
        print(f"[{directory}] FAILED Command: {command}")
        print(f"Stdout:\n{e.stdout}\nStderr:\n{e.stderr}")

        with open(LOG_FILE_PATH, "a") as f:
            f.write(f"[{timestamp}] --- FAILURE (CalledProcessError) ---\n")
            f.write(f"[CWD] {directory} FAILED Command: {command}\n")
            f.write(f"[STDOUT]\n{e.stdout}\n")
            f.write(f"[STDERR]\n{e.stderr}\n")

        return False

    # 5. Log command not found error
    except FileNotFoundError:
        print(f"[{directory}] ERROR: Command not found. Check your environment PATH or command spelling.")

        with open(LOG_FILE_PATH, "a") as f:
            f.write(f"[{timestamp}] --- ERROR (FileNotFound) ---\n")
            f.write(f"[CWD] {directory} ERROR: Command not found.\n")

        return False

def build_design(simulation_type, build_command):
    """Builds the global simulation structure once from the top directory."""
    print(f"--- Starting {simulation_type.upper()} Build ---")
    # Execute the dedicated build command from the top directory
    if not execute_command(build_command, TOP_DIR):
        print(f"{simulation_type.upper()} Build FAILED with command: {build_command}. Aborting subsequent steps.")
        return False
    print(f"--- Finished {simulation_type.upper()} Build ---")
    return True

def compile_projects():
    """Compiles all software projects sequentially within their own folders."""
    global COMPILATION_SUCCESS
    print("--- Starting Sequential Local Compilation (Software) ---")
    for folder in COMPILE_FOLDERS:
        print(f"[{folder}] Compiling with command: {COMPILE_COMMAND}")
        if not execute_command(COMPILE_COMMAND, folder):
            print(f"Compilation FAILED for {folder}. Aborting subsequent steps.")
            COMPILATION_SUCCESS = False
            break
    print("--- Finished Compilation ---")


def run_single_test_globally(test_folder_path):
    """
    Executes a single test, applies the correct conditional parameter based on the suffix,
    and cleans up wlft* files.
    """
    global RUN_COMMAND_TEMPLATE
    global PARAM_CONFIGS

    # 1. Determine the actual folder path for the command and the required suffix
    base_folder_for_cmd = test_folder_path
    extra_parameter = ""

    # Check if the path ends with any of the defined suffixes
    for suffix, param_str in PARAM_CONFIGS.items():
        if test_folder_path.endswith(suffix):
            # If it matches a suffix, strip it to get the base folder path
            base_folder_for_cmd = test_folder_path[:-len(suffix)]
            extra_parameter = param_str
            break

    # Start with the base command
    run_cmd = RUN_COMMAND_TEMPLATE.format(base_folder_for_cmd)

    # 2. --- CONDITIONAL PARAMETER APPENDING ---
    if extra_parameter:
        run_cmd += extra_parameter
        print(f"[{test_folder_path}] NOTE: Appending parameter: {extra_parameter.strip()}")

    print(f"--- Starting run for: {test_folder_path} (Final Command: {run_cmd}) ---")

    success = False

    # 3. Execute the RUN command
    try:
        # RUN is executed from the TOP_DIR
        if execute_command(run_cmd, TOP_DIR):
            print(f"[{test_folder_path}] Tests finished: SUCCESS.")
            success = True
        else:
            print(f"[{test_folder_path}] Tests finished: FAILURE during command execution.")

    except Exception as e:
        print(f"[{test_folder_path}] CRITICAL PYTHON ERROR: {type(e).__name__}: {str(e)}")
        # Log critical internal script error
        timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
        with open(LOG_FILE_PATH, "a") as f:
            f.write(f"\n[{timestamp}] --- CRITICAL PYTHON ERROR ---\n")
            f.write(f"Script internal error during test {test_folder_path}: {type(e).__name__}: {str(e)}\n")

        return f"CRITICAL FAILURE ({type(e).__name__}) in {test_folder_path}"

    # 4. **CLEANUP: Delete wlft* files**
    try:
        # Cleanup targets the base folder path where the compilation artifacts reside
        wlft_files = glob.glob(os.path.join(base_folder_for_cmd, 'wlft*'))
        if wlft_files:
            for file_path in wlft_files:
                os.remove(file_path)
            print(f"[{test_folder_path}] Cleanup: Eliminated {len(wlft_files)} wlft* files.")

    except Exception as e:
        print(f"[{test_folder_path}] WARNING: Cleanup failed for wlft* files. Error: {str(e)}")

    # 5. Return the result
    if success:
        return f"SUCCESS in {test_folder_path}"
    else:
        return f"FAILURE in {test_folder_path}"


def main():
    global COMPILATION_SUCCESS
    global RUN_COMMAND_TEMPLATE
    global RUN_FOLDERS

    # 0. Start by clearing the log file
    with open(LOG_FILE_PATH, "w") as f:
        f.write("--- TEST RUN LOG STARTED ---\n")
        f.write(f"Run started at: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")

    # 1. Parse Arguments and Set Global Variables
    args = parse_arguments()
    RUN_COMMAND_TEMPLATE = RUN_COMMAND_MAP[args.sim]

    # 2. Job Duplication Logic for tests that must run 3 times
    FINAL_RUN_FOLDERS = []

    # Add all tests that are NOT tripled
    for folder in RUN_FOLDERS:
        if folder not in RUN_TRIPLE_TESTS:
            FINAL_RUN_FOLDERS.append(folder)

    # Generate the 3 parametric jobs for each of the 3 triple tests (9 jobs total)
    for test_folder in RUN_TRIPLE_TESTS:
        for suffix in PARAM_CONFIGS.keys():
            # Create a unique job identifier: e.g., '...idma_multi_core_PARAM_A'
            parametric_job_name = test_folder + suffix
            FINAL_RUN_FOLDERS.append(parametric_job_name)

    # Logic to select and print the global build command
    design_build_command = None
    simulation_name = args.sim.upper()
    if args.sim == 'rtl':
        design_build_command = RTL_BUILD_COMMAND
    elif args.sim == 'gate':
        design_build_command = GATE_BUILD_COMMAND

    # --- PRINTING THE CONFIGURATION SUMMARY (and logging it) ---
    summary = "==================================\n"
    summary += "      TEST RUN CONFIGURATION      \n"
    summary += "==================================\n"
    summary += f"CLI Parameter: Sim Type: '{args.sim}'\n"
    summary += f"Base Tests: {len(RUN_FOLDERS)}\n"
    summary += f"Tripled Tests: {len(RUN_TRIPLE_TESTS)} (Running {len(RUN_TRIPLE_TESTS) * 3} times)\n"
    summary += f"Total Jobs to Run: {len(FINAL_RUN_FOLDERS)}\n"
    summary += f"Selected Run Command: {RUN_COMMAND_TEMPLATE}\n"

    if design_build_command:
         summary += f"{simulation_name} Build Command: {design_build_command}\n"

    summary += "=================================="

    print(summary)
    with open(LOG_FILE_PATH, "a") as f:
        f.write(f"\n{summary}\n")

    start_time = time.time()

    # Step 3: Sequential Compilation (Local Context - Compiling SW/Tests)
    compile_projects()

    if not COMPILATION_SUCCESS:
        print("\nFATAL: Local software compilation failed. Test execution aborted.")
        with open(LOG_FILE_PATH, "a") as f:
            f.write("\nFATAL: Local software compilation failed. Test execution aborted.\n")
        return

    # Step 4: Design Compilation (Executed conditionally)
    if design_build_command:
        if not build_design(simulation_name, design_build_command):
            print(f"\nFATAL: {simulation_name} compilation failed. Test execution aborted.")
            with open(LOG_FILE_PATH, "a") as f:
                f.write(f"\nFATAL: {simulation_name} compilation failed. Test execution aborted.\n")
            return

    # Step 5: Sourcing Environment (Warning remains)
    print("WARNING: Attempting to source environment script...")
    # NOTE: Sourcing with subprocess.run(shell=True) might not persist the env in the current script context.
    subprocess.run("source sw/tests/pulp-runtime/configs/opentitan-cluster.sh", shell=True)


    # Step 6: Test Execution (Global Context - Running Simulations)
    print("\n--- Starting Test Execution (from Top Dir) ---")
    results = []

    with concurrent.futures.ThreadPoolExecutor(max_workers=1) as executor:
        # Use the finalized list of jobs here
        futures = {executor.submit(run_single_test_globally, folder): folder for folder in FINAL_RUN_FOLDERS}

        for future in concurrent.futures.as_completed(futures):
            results.append(future.result())

    # --- Summary Report (and logging it) ---
    end_time = time.time()
    final_summary = "\n==================================\n"
    final_summary += "      FINAL EXECUTION SUMMARY    \n"
    final_summary += "==================================\n"
    for result in results:
        final_summary += f"Result: {result}\n"
    final_summary += f"\nTotal Time: {end_time - start_time:.2f} seconds\n"
    final_summary += "==================================\n"

    print(final_summary)
    with open(LOG_FILE_PATH, "a") as f:
        f.write(f"\n{final_summary}\n")

if __name__ == "__main__":
    main()