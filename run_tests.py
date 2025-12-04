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

# 2. Generic Command to compile.
COMPILE_COMMAND = "make clean all"

# 3. Command Templates based on netlist type
RUN_COMMAND_MAP = {
    "rtl": "make clean sim_rtl_tech_mem SRAM=sw/tests/generic_test/generic_test.elf cl-bin={}/build/test/test",
    "gate": "make clean sim_gls SRAM=sw/tests/generic_test/generic_test.elf cl-bin={}/build/test/test"
}
DEFAULT_NETLIST_TYPE = "rtl"

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

# --- Global Context ---
TOP_DIR = os.getcwd()
COMPILATION_SUCCESS = True
RUN_COMMAND_TEMPLATE = ""
MAX_RUN_WORKERS = 1

# --- Argument Parsing Function ---

def parse_arguments():
    """Defines and parses command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Run local compilation and global simulation tests in sequence.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument(
        '-j', '--jobs',
        type=int,
        default=1,
        help='Number of parallel jobs (threads) to run the simulation tests with. Default: 1 (Sequential)'
    )
    parser.add_argument(
        '--netlist',
        type=str,
        default=DEFAULT_NETLIST_TYPE,
        choices=RUN_COMMAND_MAP.keys(),
        help=f'Selects the run command template based on the netlist type. Default is "{DEFAULT_NETLIST_TYPE}".\nChoices: {list(RUN_COMMAND_MAP.keys())}'
    )
    return parser.parse_args()


# --- Utility Functions ---

def execute_command(command, directory):
    """Utility function to execute a shell command."""
    try:
        full_path = os.path.abspath(directory)
        subprocess.run(
            command,
            shell=True,
            check=True,
            cwd=full_path,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True
        )
        return True
    except subprocess.CalledProcessError as e:
        print(f"[{directory}] FAILED Command: {command}")
        print(f"Stdout:\n{e.stdout}\nStderr:\n{e.stderr}")
        return False
    except FileNotFoundError:
        print(f"[{directory}] ERROR: Command not found. Check your environment PATH or command spelling.")
        return False

def compile_projects():
    """Compiles all projects sequentially within their own folders."""
    global COMPILATION_SUCCESS
    print("--- Starting Sequential Local Compilation ---")
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
        if execute_command(run_cmd, TOP_DIR):
            print(f"[{test_folder_path}] Tests finished: SUCCESS.")
            success = True
        else:
            print(f"[{test_folder_path}] Tests finished: FAILURE during command execution.")

    except Exception as e:
        print(f"[{test_folder_path}] CRITICAL PYTHON ERROR: {type(e).__name__}: {str(e)}")
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
    global MAX_RUN_WORKERS
    global RUN_FOLDERS

    # 1. Parse Arguments and Set Global Variables
    args = parse_arguments()
    MAX_RUN_WORKERS = args.jobs
    RUN_COMMAND_TEMPLATE = RUN_COMMAND_MAP[args.netlist]

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

    # --- PRINTING THE CONFIGURATION SUMMARY ---
    print("==================================")
    print("       TEST RUN CONFIGURATION     ")
    print("==================================")
    print(f"CLI Parameter: Netlist Type: '{args.netlist}'")
    print(f"CLI Parameter: Max Jobs: {MAX_RUN_WORKERS}")
    print(f"Base Tests: {len(RUN_FOLDERS)}")
    print(f"Tripled Tests: {len(RUN_TRIPLE_TESTS)} (Running {len(RUN_TRIPLE_TESTS) * 3} times)")
    print(f"Total Jobs to Run: {len(FINAL_RUN_FOLDERS)}")
    print(f"Selected Run Command: {RUN_COMMAND_TEMPLATE}")
    print("==================================")

    start_time = time.time()

    # 3. Sourcing Environment (Warning remains)
    print("WARNING: Attempting to source environment script...")
    subprocess.run("source sw/tests/pulp-runtime/configs/opentitan-cluster.sh", shell=True)


    # Step 4: Sequential Compilation (Local Context)
    compile_projects()

    if not COMPILATION_SUCCESS:
        print("\nFATAL: Compilation failed. Test execution aborted.")
        return

    # Step 5: Sequential Test Execution (Global Context)
    print("\n--- Starting Sequential Test Execution (from Top Dir) ---")
    results = []

    with concurrent.futures.ThreadPoolExecutor(max_workers=MAX_RUN_WORKERS) as executor:
        # Use the finalized list of jobs here
        futures = {executor.submit(run_single_test_globally, folder): folder for folder in FINAL_RUN_FOLDERS}

        for future in concurrent.futures.as_completed(futures):
            results.append(future.result())

    # --- Summary Report ---
    end_time = time.time()
    print("\n==================================")
    print("       FINAL EXECUTION SUMMARY    ")
    print("==================================")
    for result in results:
        print(f"Result: {result}")
    print(f"\nTotal Time: {end_time - start_time:.2f} seconds")
    print("==================================")

if __name__ == "__main__":
    main()