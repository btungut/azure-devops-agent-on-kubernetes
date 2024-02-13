#!/bin/bash
set -e

AGENT_TOOLSDIRECTORY="/azp/_work/_tool"

# Adding ppa to fetch old python versions
add-apt-repository ppa:deadsnakes/ppa

echo "Available python version to install: $PYTHON_AVAILABLE_VERSION_VERSIONS"
for py in $PYTHON_AVAILABLE_VERSION_VERSIONS
do
  echo "--------------------------------------------------------"
  apt install -qq -y python$py-dev python$py-venv

  PYTHON_VERSION=$(python$py -V | cut -d " " -f2)
  mkdir -p $AGENT_TOOLSDIRECTORY/Python/$PYTHON_VERSION
  if [[ $? == 1 ]]; then echo "Failed created python $py version folder";exit 1;fi

  cd $AGENT_TOOLSDIRECTORY/Python/$PYTHON_VERSION
    python$py -m venv x64
    touch x64.complete
    cd x64
      mkdir -p share
      ln -s bin/python$py python
    cd ..
  cd ..

  ln -s $PYTHON_VERSION $py
  echo "Available versions:"
  tree -L 1
done
