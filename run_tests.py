import os
import subprocess
import concurrent.futures
import time

# --- Configuration ---

# 1. List of directories containing the tests and compilation setup.
COMPILE_FOLDERS = [
    "sw/tests/generic_test",
    "sw/tests/regression_tests/hello",
    "sw/tests/regression_tests/opentitan-cluster/addressability",
    "sw/tests/regression_tests/opentitan-cluster/idma_test",
    "sw/tests/regression_tests/opentitan-cluster/mbox_test",
    "sw/tests/regression_tests/parallel_bare_tests/conv16",
    "sw/tests/regression_tests/parallel_bare_tests/parMatrixMul32"
]

RUN_FOLDERS = [
    "sw/tests/regression_tests/hello",
    "sw/tests/regression_tests/opentitan-cluster/addressability",
    "sw/tests/regression_tests/opentitan-cluster/idma_test",
    "sw/tests/regression_tests/opentitan-cluster/mbox_test",
    "sw/tests/regression_tests/parallel_bare_tests/conv16",
    "sw/tests/regression_tests/parallel_bare_tests/parMatrixMul32"
]

# 2. Generic Command to compile. This runs INSIDE each TEST_FOLDER.
COMPILE_COMMAND = "make clean all"

# 3. Command to run the tests. This runs ALWAYS from the TOP FOLDER.
# Use {} as a placeholder for the CURRENT FOLDER NAME (e.g., 'alu_basic').
# The command should include a path or reference to the test setup.
# Example: 'vsim -do sim_scripts/run_{}.do'
RUN_COMMAND_TEMPLATE = "make clean sim_no_gui SRAM=sw/tests/generic_test/generic_test.elf cl-bin={}/build/test/test"

# 4. Maximum number of tests to run simultaneously.
MAX_RUN_WORKERS = 8

# --- Global Context ---
# Store the absolute path of the top-level directory where the script is executed.
TOP_DIR = os.getcwd()
COMPILATION_SUCCESS = True

# --- Utility Functions ---

def execute_command(command, directory):
    """Utility function to execute a shell command."""
    try:
        full_path = os.path.abspath(directory)

        # --- CHANGE IS HERE ---
        # 1. Using explicit PIPE for stdout/stderr (replaces capture_output=True)
        # 2. Using universal_newlines=True (replaces text=True)
        subprocess.run(
            command,
            shell=True,
            check=True,
            cwd=full_path,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True  # <--- Use this instead of text=True
        )
        # --- END CHANGE ---

        return True
    except subprocess.CalledProcessError as e:
        # The capture_output argument is what allows 'e.stdout' and 'e.stderr'
        # to be accessed directly after a failure when using Python 3.7+.
        # In Python 3.6, this part might need adjustment if you were trying to
        # print the error output, but since your code doesn't explicitly read the
        # result of subprocess.run (it only checks for exceptions), this section
        # should still work fine for error logging IF you were using stdout/stderr=PIPE.

        print(f"[{directory}] FAILED Command: {command}")
        # Note: If this section raises a new error about e.stdout/e.stderr not existing,
        # you may need to save the result of subprocess.run() and access the pipes
        # from the result object in Python 3.6. However, for most simple logging
        # cases, the fix above is sufficient.
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

        # Execute the generic command within the test folder
        if not execute_command(COMPILE_COMMAND, folder):
            print(f"Compilation FAILED for {folder}. Aborting subsequent steps.")
            COMPILATION_SUCCESS = False
            break

    print("--- Finished Compilation ---")


def run_single_test_globally(test_folder_path):
    """Runs a single test from the TOP_DIR using a customized command with the full path."""

    # 1. Customize RUN command: Inject the full relative path into the template
    run_cmd = RUN_COMMAND_TEMPLATE.format(test_folder_path)
    test_dir_name = os.path.basename(test_folder_path)

    print(f"--- Starting run for: {test_dir_name} (Command: {run_cmd}) ---")

    # 2. Execute command from the TOP_DIR (Global Context)
    if execute_command(run_cmd, TOP_DIR):
        print(f"[{test_dir_name}] Tests finished: SUCCESS.")
        return f"SUCCESS in {test_dir_name} test"
    else:
        print(f"[{test_dir_name}] Tests finished: FAILURE.")
        return f"FAILURE (Run) in {test_folder_path} test"

def main():
    start_time = time.time()

    # Step 1: Sequential Compilation (Local Context)
    compile_projects()

    if not COMPILATION_SUCCESS:
        print("\nFATAL: Compilation failed. Test execution aborted.")
        return

    # Step 2: Parallel Test Execution (Global Context)
    print("\n--- Starting Parallel Test Execution (from Top Dir) ---")
    results = []

    with concurrent.futures.ThreadPoolExecutor(max_workers=MAX_RUN_WORKERS) as executor:
        # Submit all run jobs, passing only the folder name for command customization
        futures = {executor.submit(run_single_test_globally, folder) for folder in RUN_FOLDERS}

        # Collect results as they complete
        for future in concurrent.futures.as_completed(futures):
            results.append(future.result())

    # --- Summary Report ---
    end_time = time.time()
    print("\n==================================")
    print("      FINAL EXECUTION SUMMARY     ")
    print("==================================")
    for result in results:
        print(f"Result: {result}")
    print(f"\nTotal Time: {end_time - start_time:.2f} seconds")
    print("==================================")

if __name__ == "__main__":
    main()