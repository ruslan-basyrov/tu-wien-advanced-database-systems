import os
import subprocess
import glob

configfile: "config/config.yaml"
container: "docker://verity:latest"

IMAGE = "verity:latest"
DOCKER_RUN = f'docker run --rm -u $(id -u):$(id -g) -e HOME=/tmp -v "${{PWD}}":/workspace -w /workspace {IMAGE}'

# ---- Report's files --------------------------------------------------------
QMD_FILES = glob.glob("reports/*.qmd")
HTML_OUTS = [f.replace("reports/", "reports/_acuity/").replace(".qmd", ".html") for f in QMD_FILES]

rule all:
    input:
        "reports/_acuity/index.html",


# ---- Docker image ---------------------------------------------------------
rule build_image:
    input:
        "Dockerfile",
        "Manifest.toml",
        "pyproject.toml",
    output:
        ".docker_built",
    shell:
        "docker build -t {IMAGE} . && touch {output}"


# --- Analysis pipeline -----------------------------------------------------
rule process_data:
    input:
        flag=".docker_built",
        raw=config["data"]["raw"],
    output:
        processed=config["data"]["processed"],
    shell:
        "{DOCKER_RUN} python3 src/process_data.py --input {input.raw} --output {output.processed}"

rule analyse:
    input:
        flag=".docker_built",
        data=config["data"]["processed"],
    output:
        figure="results/figures/analysis.png",
    shell:
        "{DOCKER_RUN} Rscript src/analyse.R {input.data} {output.figure}"

rule install_quarto_ext:
    input:
        flag=".docker_built",
    output:
        "reports/_extensions/ruslan-basyrov/acuity/_extension.yml",
    shell:
        '{DOCKER_RUN} bash -c "cd reports && quarto add ruslan-basyrov/acuity --no-prompt"'

rule render_report:
    input:
        flag=".docker_built",
        ext="reports/_extensions/ruslan-basyrov/acuity/_extension.yml",
        qmd="reports/index.qmd",
        quarto_config="reports/_quarto.yml",
    output:
        html="reports/_acuity/index.html",
    shell:
        """
        {DOCKER_RUN} quarto render reports/
        """
