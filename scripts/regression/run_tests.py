import os
import subprocess
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
    "sw/tests/regression_tests/opentitan-cluster/dmr_matmul",
    "sw/tests/regression_tests/opentitan-cluster/ecc_test",
    "sw/tests/regression_tests/opentitan-cluster/neureka",
    "sw/tests/regression_tests/opentitan-cluster/conv16",
    "sw/tests/regression_tests/opentitan-cluster/parMatrixMul8",
    "sw/tests/regression_tests/opentitan-cluster/parMatrixMul16",
    "sw/tests/regression_tests/opentitan-cluster/parMatrixMul32",
    "sw/tests/regression_tests/opentitan-cluster/idma_multi_core",
    "sw/tests/regression_tests/opentitan-cluster/idma_multi_core_2d",
    "sw/tests/regression_tests/opentitan-cluster/idma_multi_core_3d"
]
RUN_FOLDERS = [
    "sw/tests/regression_tests/hello",
    "sw/tests/regression_tests/opentitan-cluster/addressability",
    "sw/tests/regression_tests/opentitan-cluster/idma_test",
    "sw/tests/regression_tests/opentitan-cluster/mbox_test",
    "sw/tests/regression_tests/opentitan-cluster/dmr_matmul",
    "sw/tests/regression_tests/opentitan-cluster/ecc_test",
    "sw/tests/regression_tests/opentitan-cluster/neureka",
    "sw/tests/regression_tests/opentitan-cluster/conv16",
    "sw/tests/regression_tests/opentitan-cluster/parMatrixMul8",
    "sw/tests/regression_tests/opentitan-cluster/parMatrixMul16",
    "sw/tests/regression_tests/opentitan-cluster/parMatrixMul32",
    "sw/tests/regression_tests/opentitan-cluster/idma_multi_core",
    "sw/tests/regression_tests/opentitan-cluster/idma_multi_core_2d",
    "sw/tests/regression_tests/opentitan-cluster/idma_multi_core_3d"
]
# 2. Generic Command to compile Cluster Test applications.
COMPILE_COMMAND = "make clean all"

# 3. Command Templates based on simulation type
RUN_COMMAND_MAP = {
    "rtl": "make sim_rtl SRAM=sw/tests/generic_test/generic_test.elf cl-bin={}/build/test/test",
    "rtl_tech": "make sim_rtl_tech_mem SRAM=sw/tests/generic_test/generic_test.elf cl-bin={}/build/test/test",
    "gate": "make sim_gls_run SRAM=sw/tests/generic_test/generic_test.elf cl-bin={}/build/test/test"
}
DEFAULT_SIMULATION_TYPE = "rtl"

# 4. Tests that need to be run 3 TIMES (These are the last 3 entries in RUN_FOLDERS)
RUN_TRIPLE_TESTS = [
    "sw/tests/regression_tests/opentitan-cluster/idma_multi_core",
    "sw/tests/regression_tests/opentitan-cluster/idma_multi_core_2d",
    "sw/tests/regression_tests/opentitan-cluster/idma_multi_core_3d"
]

# 5. Definitions for the three unique parametric runs
PARAM_CONFIGS = {
    "_PARAM_A": " QUICK_MODE=1",
    "_PARAM_B": " MULTI_CORE_S=1",
    "_PARAM_C": " MULTI_CORE_P=1"
}

# 6. Design Compilation Commands (Run once from TOP_DIR)
RTL_BUILD_COMMAND = "make clean build opt_rtl"
RTL_TECH_BUILD_COMMAND = "make clean build_tech_mem opt_rtl"
GATE_BUILD_COMMAND = "make clean sim_gls_compile"

# 7. OT Test Configuration
# List of OT tests to be built and run
OT_TEST_LIST = ["idma_test"]
OT_TARGET = "opentitan"

# Templates for OT Build and Run
OT_TEST_BUILD_TEMPLATE = "make compile-bazel-sram test_name={} target={}"
OT_TEST_RUN_TEMPLATES = {
    "rtl": "make sim_rtl SRAM=sw/tests/opentitan/{}/bazel-out/{}.elf",
    "rtl_tech": "make sim_rtl_tech_mem SRAM=sw/tests/opentitan/{}/bazel-out/{}.elf",
    "gate": "make sim_gls_run SRAM=sw/tests/opentitan/{}/bazel-out/{}.elf"
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
        choices=RUN_COMMAND_MAP.keys(),
        help=f'Selects the simulation type (RTL, RTL with tech memories or Gate-Level). Default is "{DEFAULT_SIMULATION_TYPE}".\nChoices: {list(RUN_COMMAND_MAP.keys())}'
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
        print(f"FAILED Command: {command}")
        with open(LOG_FILE_PATH, "a") as f:
            f.write(f"[{timestamp}] --- FAILURE (CalledProcessError) ---\n")
            f.write(f"[CWD] {directory} FAILED Command: {command}\n")
            f.write(f"[STDOUT]\n{e.stdout}\n")
            f.write(f"[STDERR]\n{e.stderr}\n")
        return False

    except FileNotFoundError:
        print(f"[{directory}] ERROR: Command not found.")
        return False

def build_design(simulation_name, build_command):
    """Builds the hardware design (RTL or Gate) before running tests."""
    print(f"\n--- Starting {simulation_name} Design Build ---")
    success = execute_command(build_command, TOP_DIR)
    if not success:
        print(f"FATAL: {simulation_name} build failed. Aborting.")
        return False
    print(f"--- {simulation_name} Design Build Finished ---")
    return True

def compile_projects():
    """Compiles Cluster Test apps sequentially."""
    global COMPILATION_SUCCESS
    print("\n--- Starting Cluster Tests Compilation ---")
    for folder in COMPILE_FOLDERS:
        print(f"[{folder}] Compiling...")
        if not execute_command(COMPILE_COMMAND, folder):
            print(f"Compilation FAILED for {folder}. Aborting subsequent steps.")
            COMPILATION_SUCCESS = False
            break
    print("--- Finished Cluster Tests Compilation ---")

def run_single_test_globally(test_name):
    """Executes a simulation sequence, handling parametric suffixes and cleanup."""
    global RUN_COMMAND_TEMPLATE
    global PARAM_CONFIGS

    base_folder = test_name
    extra_parameter = ""

    # Resolve parametric name to real folder path
    for suffix, param_str in PARAM_CONFIGS.items():
        if test_name.endswith(suffix):
            base_folder = test_name[:-len(suffix)]
            extra_parameter = param_str
            break

    run_cmd = RUN_COMMAND_TEMPLATE.format(base_folder) + extra_parameter
    print(f"--- Running: {test_name} ---")

    success = False
    try:
        if execute_command(run_cmd, TOP_DIR):
            print(f"[{test_name}] SUCCESS.")
            success = True
        else:
            print(f"[{test_name}] FAILURE.")

    except Exception as e:
        print(f"[{test_name}] Python Error: {str(e)}")
        return f"ERROR in {test_name}"

    # Cleanup simulation artifacts
    try:
        wlft_files = glob.glob(os.path.join(base_folder, 'wlft*'))
        for f in wlft_files:
            os.remove(f)
    except Exception:
        pass

    return f"{'SUCCESS' if success else 'FAILURE'} in {test_name}"

def main():
    global COMPILATION_SUCCESS
    global RUN_COMMAND_TEMPLATE

    # Init log
    with open(LOG_FILE_PATH, "w") as f:
        f.write(f"Test Run Log - Started: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")

    args = parse_arguments()
    RUN_COMMAND_TEMPLATE = RUN_COMMAND_MAP[args.sim]

    # Expand Test Sequence
    FINAL_RUN_SEQUENCE = []
    for folder in RUN_FOLDERS:
        if folder not in RUN_TRIPLE_TESTS:
            FINAL_RUN_SEQUENCE.append(folder)

    for test_folder in RUN_TRIPLE_TESTS:
        for suffix in PARAM_CONFIGS.keys():
            FINAL_RUN_SEQUENCE.append(test_folder + suffix)

    # Determine hardware build command
    build_cmd = None
    if args.sim == 'rtl': build_cmd = RTL_BUILD_COMMAND
    elif args.sim == 'rtl_tech': build_cmd = RTL_TECH_BUILD_COMMAND
    elif args.sim == 'gate': build_cmd = GATE_BUILD_COMMAND

    print(f"Mode: {args.sim.upper()}")
    print(f"Total Tests to Run: {len(FINAL_RUN_SEQUENCE)}")

    start_time = time.time()
    results = []

    # Environment Sourcing
    print("Sourcing environment config...")
    subprocess.run("source sw/tests/pulp-runtime/configs/opentitan-cluster.sh", shell=True)

    # Step 1: Cluster Test Compilation
    compile_projects()
    if not COMPILATION_SUCCESS:
        results.append("FAILURE in Cluster Test Compilation")
        summary_and_exit(results, start_time)
        return
    results.append("SUCCESS in Cluster Test Compilation")

    # Step 2: Opentitan Test Build Command
    print("\n--- Starting Opentitan Tests Compilation ---")
    ot_comp_fail = False
    for ot_test in OT_TEST_LIST:
        ot_build_cmd = OT_TEST_BUILD_TEMPLATE.format(ot_test, OT_TARGET)
        print(f"[sw/tests/opentitan/{ot_test}] Compiling...")
        if not execute_command(ot_build_cmd, TOP_DIR):
            print(f"FATAL: Opentitan Test Build failed for {ot_test}. Aborting.")
            ot_comp_fail = True
            break

    if ot_comp_fail:
        results.append("FAILURE in Opentitan Tests Compilation")
        summary_and_exit(results, start_time)
        return

    results.append("SUCCESS in Opentitan Tests Compilation")
    print("--- Finished Opentitan Tests Compilation ---")

    # Step 3: Hardware Build (Simulation specific)
    if build_cmd:
        hw_build_success = build_design(args.sim.upper(), build_cmd)
        if not hw_build_success:
            results.append(f"FAILURE in {args.sim.upper()} Design Build")
            summary_and_exit(results, start_time)
            return
        results.append(f"SUCCESS in {args.sim.upper()} Design Build")

    # Step 4: Cluster Tests Simulation
    print("\n--- Starting Cluster Tests Simulation ---")
    for test_item in FINAL_RUN_SEQUENCE:
        result = run_single_test_globally(test_item)
        results.append(result)

    # Step 5: Opentitan Test Run Command
    ot_run_template = OT_TEST_RUN_TEMPLATES.get(args.sim)
    print("\n--- Starting Opentitan Tests Simulation ---")
    if ot_run_template:
        for ot_test in OT_TEST_LIST:
            # Format the run command using the test name for both path and elf filename
            print(f"--- Running: sw/tests/opentitan/{ot_test} ---")
            ot_run_cmd = ot_run_template.format(ot_test, ot_test)
            ot_run_success = execute_command(ot_run_cmd, TOP_DIR)

            if ot_run_success:
                results.append(f"SUCCESS in sw/tests/opentitan/{ot_test}")
            else:
                results.append(f"FAILURE in sw/tests/opentitan/{ot_test}")

    summary_and_exit(results, start_time)

def summary_and_exit(results, start_time):
    """Prints the final summary report and logs it."""
    end_time = time.time()
    summary_block = "\n" + "="*34 + "\n      FINAL SUMMARY\n" + "="*34 + "\n"
    for r in results: summary_block += f"{r}\n"
    summary_block += f"\nTotal Time: {end_time - start_time:.2f}s\n" + "="*34

    print(summary_block)
    with open(LOG_FILE_PATH, "a") as f:
        f.write(f"\n{summary_block}\n")

if __name__ == "__main__":
    main()