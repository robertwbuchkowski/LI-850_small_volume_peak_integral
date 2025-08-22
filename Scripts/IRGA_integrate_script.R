# A script to integrate and save IRGA time series data:
# A: Robert Buchkowski
# D: Aug 21,2025

# Load libraries:
library(tidyverse)
library(readxl)
library(hms)

# Do you want to see graphs?
verbose = T

# Set the times:

# How many seconds after the injection does the peak start (make sure to leave a few second buffer)?
peak_delay = 15

# How many seconds should be used to establish the baseline?
baseline_length = 20

# How many second does the peak last?
peak_length = 60

# Load in data:
folder_name = "EXAMPLE_DATA"

log1 = read_table(paste0(folder_name,"/IRGA_output.txt"), skip = 1)

log1_t = read_csv(paste0(folder_name,"/IRGA_times.csv"))

colnames(log1) = c("Date", "Time", "CO2", "H2O", "H2O_C", "Celltemp", "Cellpress", "CO2abs", "H2Oabs", "InVolt", "Flow","X12")

log1 = log1 %>% mutate(Time = as_hms(Time))

if(verbose) log1 %>% ggplot(aes(x = Time, y =CO2)) + geom_line()

log1_t = log1_t %>%
  mutate(Time_Inject = as_hms(Time_Inject))

log1_t = log1_t %>%
  filter(!is.na(Time_Inject)) %>%
  mutate(peak_starts = as_hms(Time_Inject + hms(seconds = peak_delay))) %>%
  mutate(peak_lengths = hms(seconds = peak_length),
         baseline_back = hms(seconds = baseline_length))


# Load function:
source("Scripts/integrate_peaks.R")

# Integrate:
op = integrate_peaks(log1 %>% select(Time, CO2),
                     peak_starts = log1_t$peak_starts,
                     peak_lengths = log1_t$peak_lengths,
                     baseline_back = log1_t$baseline_back,
                     toplot = F,
                     cutoff_above_baseline = 1)

# Plot the baseline values over time:
if(verbose) op %>% ggplot(aes(x = peak_start, y = baseline)) + geom_point()

# Add the area to the input dataset:
log1_t = log1_t %>%
  mutate(baseline = op$baseline,
         AUC = op$area_under_peak)

stds =log1_t %>%
  filter(Standard == 1)

stds %>%
  group_by(Identification) %>%
  summarize(A = mean(AUC), SD = sd(AUC)) %>%
  mutate(PV = SD/A*100)

# Write out the raw data and results in standard file formats:

log1_t %>% write_csv(paste0(folder_name, "/integrated_output.csv"))
log1 %>% write_csv(paste0(folder_name, "/raw_IRGA_output_processed.csv"))
