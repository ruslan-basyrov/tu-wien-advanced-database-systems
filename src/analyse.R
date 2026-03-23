# Statistical analysis and visualisation script.
#
# Reads processed data, produces figures in results/figures/.
# Called by Snakemake: Rscript src/analyse.R <input_data> <output_figure>

library(tidyverse)

args <- commandArgs(trailingOnly = TRUE)
input_path <- args[1]
output_path <- args[2]

# Ensure output directory exists
dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)

# TODO: Replace with your actual analysis logic.
# Placeholder: read data and create a simple plot.
data <- read_csv(input_path)

p <- ggplot(data, aes(x = x, y = y)) +
  geom_point() +
  theme_minimal() +
  labs(title = "Analysis Results")

ggsave(output_path, plot = p, width = 8, height = 5, dpi = 300)
