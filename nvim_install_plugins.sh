#!/bin/bash

# neovim
# flake8 vim-khuno
# python-autopep8 python3-autopep8 python3-pep8 python3-pytest-pep8 vim-autopep8
# pylama
# python3-pylama
# python3-flake8-polyfill python3-pep8-naming
# pyflakes3 python3-flake8 python3-flake8-polyfill python3-pyflakes
# python3-pylint-celery python3-pylint-common python3-pylint-django python3-pylint-flask  python3-pylint-plugin-utils

packages="neovim flake8 vim-khuno python3-pep8 python3-pytest-pep8 vim-autopep8 pylama python3-pylama python3-flake8-polyfill python3-pep8-naming pyflakes3 python3-flake8 python3-flake8-polyfill python3-pyflakes python3-pylint-django python3-pylint-plugin-utils make exuberant-ctags jq ack shellcheck cmake black"

# shellcheck disable=SC2086
sudo apt-get $1 $2 $3 $4 install -y $packages
# shellcheck disable=SC2086
sudo apt-get $1 $2 $3 $4 install -y python3-pylint-flask
# shellcheck disable=SC2086
sudo apt-get $1 $2 $3 $4 install -y python3-autopep8 || sudo apt-get $1 $2 $3 $4 install python-autopep8
# shellcheck disable=SC2086
sudo apt-get $1 $2 $3 $4 install -y python3-pylint-celery
# shellcheck disable=SC2086
sudo apt-get $1 $2 $3 $4 install -y python3-pylint-common
# shellcheck disable=SC2086
pip install python-dotenv requests pynvim==0.5.0 prompt-toolkit ripgrep
