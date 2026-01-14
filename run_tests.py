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
CLS_TEST_COMPILE_COMMAND = "make clean all"

# 3. Command Templates based on simulation type
CLS_TEST_RUN_COMMAND_MAP = {
    "rtl": "make sim_rtl SRAM=sw/tests/generic_test/generic_test.elf cl-bin={}/build/test/test",
    "rtl_tech": "make sim_rtl_tech_mem SRAM=sw/tests/generic_test/generic_test.elf cl-bin={}/build/test/test",
    "gate": "make sim_gls_run SRAM=sw/tests/generic_test/generic_test.elf cl-bin={}/build/test/test"
}
DEFAULT_SIMULATION_TYPE = "rtl"

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
RTL_BUILD_COMMAND = "make build"
RTL_TECH_BUILD_COMMAND = "make build_tech_mem"
GATE_BUILD_COMMAND = "make sim_gls_compile"

# 7. Additional Test Run Commands (Run once from TOP_DIR after all simulations)
OT_TEST_RUN_MAP = {
    "rtl": "make sim_rtl SRAM=sw/tests/opentitan/idma_test/bazel-out/idma_test.elf",
    "rtl_tech": "make sim_rtl_tech_mem SRAM=sw/tests/opentitan/idma_test/bazel-out/idma_test.elf",
    "gate": "make sim_gls_run SRAM=sw/tests/opentitan/idma_test/bazel-out/idma_test.elf"
}

# --- Global Context ---
TOP_DIR = os.getcwd()
COMPILATION_SUCCESS = True
RUN_COMMAND_TEMPLATE = ""
LOG_FILE_PATH = "test_run.log"

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
        default=DEFAULT_SIMULATION_TYPE,
        choices=CLS_TEST_RUN_COMMAND_MAP.keys(),
        help=f'Selects the simulation type (RTL, RTL with tech memories or Gate-Level). Default is "{DEFAULT_SIMULATION_TYPE}".\nChoices: {list(CLS_TEST_RUN_COMMAND_MAP.keys())}'
    )
    return parser.parse_args()


# --- Utility Functions ---

def execute_command(command, directory):
    """Utility function to execute a shell command and log its output."""
    timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
    full_path = os.path.abspath(directory)

    with open(LOG_FILE_PATH, "a") as f:
        f.write(f"\n==================================\n")
        f.write(f"[{timestamp}] --- EXECUTING ---\n")
        f.write(f"[CWD] {full_path}\n")
        f.write(f"[CMD] {command}\n")

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

        with open(LOG_FILE_PATH, "a") as f:
            f.write(f"[{timestamp}] --- SUCCESS ---\n")
            f.write(f"[STDOUT (Excerpt)]\n{result.stdout[:1000]}...\n" if result.stdout else "[STDOUT] (No output)\n")

        return True

    except subprocess.CalledProcessError as e:
        print(f"[{directory}] FAILED Command: {command}")
        with open(LOG_FILE_PATH, "a") as f:
            f.write(f"[{timestamp}] --- FAILURE (CalledProcessError) ---\n")
            f.write(f"[STDOUT]\n{e.stdout}\n")
            f.write(f"[STDERR]\n{e.stderr}\n")
        return False

    except FileNotFoundError:
        print(f"[{directory}] ERROR: Command not found.")
        return False

def build_design(simulation_name, build_command):
    """Builds the hardware design (RTL or Gate) before running tests."""
    print(f"--- Starting {simulation_name} Design Build ---")
    if not execute_command(build_command, TOP_DIR):
        print(f"FATAL: {simulation_name} build failed. Aborting.")
        return False
    print(f"--- {simulation_name} Design Build Finished ---")
    return True

def compile_projects():
    """Compiles software test apps sequentially."""
    global COMPILATION_SUCCESS
    print("--- Starting Software Compilation ---")
    for folder in COMPILE_FOLDERS:
        print(f"[{folder}] Compiling...")
        if not execute_command(CLS_TEST_COMPILE_COMMAND, folder):
            print(f"Compilation FAILED for {folder}.")
            COMPILATION_SUCCESS = False
            break
    print("--- Finished Software Compilation ---")

def run_single_test_globally(test_job_name):
    """Executes a simulation job, handling parametric suffixes and cleanup."""
    global RUN_COMMAND_TEMPLATE
    global PARAM_CONFIGS

    base_folder = test_job_name
    extra_parameter = ""

    # Resolve parametric job name to real folder path
    for suffix, param_str in PARAM_CONFIGS.items():
        if test_job_name.endswith(suffix):
            base_folder = test_job_name[:-len(suffix)]
            extra_parameter = param_str
            break

    run_cmd = RUN_COMMAND_TEMPLATE.format(base_folder) + extra_parameter
    print(f"--- Running: {test_job_name} ---")

    success = False
    try:
        if execute_command(run_cmd, TOP_DIR):
            print(f"[{test_job_name}] SUCCESS.")
            success = True
        else:
            print(f"[{test_job_name}] FAILURE.")

    except Exception as e:
        print(f"[{test_job_name}] Python Error: {str(e)}")
        return f"ERROR in {test_job_name}"

    # Cleanup simulation artifacts
    try:
        wlft_files = glob.glob(os.path.join(base_folder, 'wlft*'))
        for f in wlft_files:
            os.remove(f)
    except Exception:
        pass

    return f"{'SUCCESS' if success else 'FAILURE'} in {test_job_name}"

def main():
    global COMPILATION_SUCCESS
    global RUN_COMMAND_TEMPLATE

    # Init log
    with open(LOG_FILE_PATH, "w") as f:
        f.write(f"Test Run Log - Started: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")

    args = parse_arguments()
    RUN_COMMAND_TEMPLATE = CLS_TEST_RUN_COMMAND_MAP[args.sim]

    # Expand Jobs (Handle the 3x Triple-Test logic)
    FINAL_RUN_FOLDERS = []
    for folder in RUN_FOLDERS:
        if folder not in RUN_TRIPLE_TESTS:
            FINAL_RUN_FOLDERS.append(folder)

    for test_folder in RUN_TRIPLE_TESTS:
        for suffix in PARAM_CONFIGS.keys():
            FINAL_RUN_FOLDERS.append(test_folder + suffix)

    # Determine hardware build command
    build_cmd = None
    if args.sim == 'rtl': build_cmd = RTL_BUILD_COMMAND
    elif args.sim == 'rtl_tech': build_cmd = RTL_TECH_BUILD_COMMAND
    elif args.sim == 'gate': build_cmd = GATE_BUILD_COMMAND

    # Determine additional test run command
    post_run_cmd = OT_TEST_RUN_MAP.get(args.sim)

    print(f"Mode: {args.sim.upper()}")
    print(f"Total Jobs: {len(FINAL_RUN_FOLDERS)}")

    start_time = time.time()

    # Step 1: Software Compilation
    compile_projects()
    if not COMPILATION_SUCCESS: return

    # Step 2: Hardware Build
    if build_cmd:
        if not build_design(args.sim.upper(), build_cmd): return

    # Step 3: Environment Sourcing (Note: limited impact on current process)
    print("Sourcing environment config...")
    subprocess.run("source sw/tests/pulp-runtime/configs/opentitan-cluster.sh", shell=True)

    # Step 4: Parallel Test Execution
    print("\n--- Starting Simulation Execution ---")
    results = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=1) as executor:
        futures = {executor.submit(run_single_test_globally, job): job for job in FINAL_RUN_FOLDERS}
        for future in concurrent.futures.as_completed(futures):
            results.append(future.result())

    # Step 5: Final Extra Command (Selected based on --sim)
    if post_run_cmd:
        print(f"\n--- Executing Post-Run Command for {args.sim.upper()} ---")
        execute_command(post_run_cmd, TOP_DIR)

    # Summary
    end_time = time.time()
    summary_block = "\n" + "="*34 + "\n      FINAL SUMMARY\n" + "="*34 + "\n"
    for r in results: summary_block += f"{r}\n"
    summary_block += f"\nTotal Time: {end_time - start_time:.2f}s\n" + "="*34

    print(summary_block)
    with open(LOG_FILE_PATH, "a") as f: f.write(summary_block)

if __name__ == "__main__":
    main()