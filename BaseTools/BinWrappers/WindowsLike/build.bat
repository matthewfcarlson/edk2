@setlocal
@set ToolName=%~n0%
@%PYTHON_COMMAND% -m edk2toolbase.build.build %*
