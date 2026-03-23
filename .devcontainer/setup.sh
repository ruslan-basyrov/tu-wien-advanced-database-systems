#!/bin/bash

echo "Restoring Python environment via uv..."
if [ -f "pyproject.toml" ]; then
    uv sync
fi

echo "Restoring R environment via renv..."
if [ -f "renv.lock" ]; then
    Rscript -e 'renv::restore(prompt = FALSE)'
fi

echo "Restoring Julia environment via Pkg..."
if [ -f "Project.toml" ]; then
    julia --project=. -e 'using Pkg; Pkg.instantiate()'
fi

echo "All environments restored!"


quarto add ruslan-basyrov/acuity --no-prompt

echo "Acuity is installed/updated (a Quarto extension)"
