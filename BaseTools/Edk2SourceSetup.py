# @file Edk2SourceSetup.py
# This code bootstraps a virtual environment if one does not exist and does a pip install
#
##
# Copyright (c) Microsoft Corporation
#
# SPDX-License-Identifier: BSD-2-Clause-Patent
##

import venv
import os
import sys
import subprocess


def activate_venv(venv_folder=None):
    ''' activates the virtual environment, scraps the shell environ, and applies it '''
    if venv_folder is None:
        venv_folder = get_venv_folder()
    if os.name == 'nt':
        script_file = "activate.bat"
        env_list_cmd = "set"
    else:
        script_file = "activate"
        env_list_cmd = "printenv"

    script_file_path = os.path.join(venv_folder, "Scripts", script_file)
    if not os.path.exists(script_file_path):
        print("Please reinit your virtual environment")

    # Create a subprocess that inits the environment
    # Inspiration taken from cpython for this method of env collection
    # Then we scrap the resulting environment

    popen = subprocess.Popen('"%s" & %s' % (script_file_path, env_list_cmd),
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    environ_we_care_about = ["PROMPT", "PATH", "VIRTUAL_ENV", "PYTHONHOME",
                             "_OLD_VIRTUAL_PROMPT", "_OLD_VIRTUAL_PYTHONHOME", "_OLD_VIRTUAL_PATH"]
    environ_results = {}
    try:
        stdout, stderr = popen.communicate()
        if popen.wait() != 0:
            raise Exception(stderr.decode("mbcs"))
        stdout = stdout.decode("mbcs")
        for line in stdout.split("\n"):
            if '=' not in line:
                continue
            line = line.strip()
            key, value = line.split('=', 1)
            if key.upper() in environ_we_care_about:
                if value.endswith(os.pathsep):
                    value = value[:-1]
                environ_results[key] = value
    finally:
        popen.stdout.close()
        popen.stderr.close()

    # Apply what we found to the current environment
    for environ_key in environ_results:
        environ_value = environ_results[environ_key]
        # print(f"Setting {environ_key} = {environ_value}")
        os.environ[environ_key] = environ_value

    # the problem is that the environment changes we made are only for this python process


def pip_install():
    # we are going to find the first pip-requirements.txt folder we can
    folders_to_look_in = [os.environ["WORKSPACE"], os.environ["BASE_TOOLS_PATH"],
                          os.path.dirname(os.environ["BASE_TOOLS_PATH"])]
    found_pip_file = None
    for looking_folder in folders_to_look_in:
        # look for a pip-requirements.txt
        if looking_folder is None:
            continue
        pip_file = os.path.join(looking_folder, "pip-requirements.txt")
        if not os.path.exists(pip_file):
            continue
        found_pip_file = pip_file
        break

    if found_pip_file is None:
        print("We failed to find pip-requirements.txt")
        sys.exit(3)

    # now we do a pip install -r pip_requirements --upgrade
    popen = subprocess.Popen('pip install -r "%s" --upgrade' % (found_pip_file),
                             stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        stdout, stderr = popen.communicate()
        result = popen.wait()
        if result != 0:
            print("We failed to install pip requirements")
            print(stdout)
            print(stderr)
        return result
    finally:
        popen.stdout.close()
        popen.stderr.close()

    return 0


def get_venv_folder():
    root = os.environ.get("BASE_TOOLS_PATH")
    # make sure we at least have basetools
    if not os.path.exists(root):
        print("BASE_TOOLS_PATH is not set")
        sys.exit(1)
    return os.path.join(root, ".venv")


def main():
    ''' the main function '''
    print("Setting up virtual environment")

    # Check if we have a basetools path already - let's use that
    venv_folder = get_venv_folder()

    # if the environment does not exist, create it
    if not os.path.exists(venv_folder):
        print("Setting up virtual environment at " + venv_folder)
        builder = venv.EnvBuilder(with_pip=True)
        builder.create(venv_folder)

    # activate the environment if it's not active
    if os.environ.get("VIRTUAL_ENV") != venv_folder:
        print("Activating Virtual environment")
        activate_venv(venv_folder)

    if os.environ.get("VIRTUAL_ENV") != venv_folder:
        print("Failed to activate virtual environment")
        sys.exit(2)

    # do the pip install
    pip_install()

    # Use basetools python if they already exist
    python_source = os.environ.get("BASETOOLS_PYTHON_SOURCE")
    if python_source is not None and os.path.exists(python_source):
        print("Using the source that you already have: " + python_source)
        # do a pip install -e python_source
        popen = subprocess.Popen('pip install -e "%s"' % (python_source))
        result = popen.wait()
        if result != 0:
            print("We failed to install this locally")

    try:
        from edk2toolbase import build
    except ImportError:
        print("We don't EDK2 BaseTools installed")
        sys.exit(3)


if __name__ == "__main__":
    main()
