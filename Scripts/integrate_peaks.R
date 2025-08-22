# Function to integrate under specified peaks
integrate_peaks <- function(data, peak_starts, peak_lengths, baseline_back, toplot = F, cutoff_above_baseline = 1) {
  # Ensure inputs are the same length
  stopifnot(length(peak_starts) == length(peak_lengths))

  peak_end = peak_starts + peak_lengths

  baseline_start = peak_starts - baseline_back

  output = vector(mode = "list", length(peak_starts))

  for(i in 1:length(peak_starts)){
    # Filter data for the current peak
    segment <- data %>%
      filter(Time >= peak_starts[i] & Time <= peak_end[i]) %>%
      arrange(Time)

    baseline <- data %>%
      filter(Time >= baseline_start[i] & Time <= peak_starts[i]) %>%
      arrange(Time) %>%
      pull(CO2) %>%
      mean()

    if(toplot) print(baseline)

    segment$CO2 = segment$CO2 - baseline

    # Cut-off above baseline:
    segment = segment %>% mutate(AB = CO2 > cutoff_above_baseline)

    # Identify runs of TRUE values
    runs <- rle(segment$AB)

    # Find the start and end indices of each run
    ends <- cumsum(runs$lengths)
    starts <- ends - runs$lengths + 1

    # Filter for runs where AB is TRUE
    true_runs <- which(runs$values)

    # Get the longest continuous TRUE run (or first if multiple equal)
    longest_run_index <- true_runs[which.max(runs$lengths[true_runs])]
    first_row <- starts[longest_run_index]
    last_row <- ends[longest_run_index]

    # Output the rows
    segment = segment[c((first_row):(last_row)), ]

    if(toplot) print(segment %>%
                       ggplot(aes(x = Time, y =CO2)) +geom_line())

    segment = segment %>%
      mutate(seconds = as.numeric(Time),
             seconds_from_zero = seconds - min(seconds))

    # Apply trapezoidal rule
    dt <- diff(segment$seconds_from_zero)
    dt = 0.5 # Known logging rate!
    avg_CO2 <- (head(segment$CO2, -1) + tail(segment$CO2, -1)) / 2
    area <- sum(dt * avg_CO2)

    output[[i]] = tibble(
      peak_start = as_hms(peak_starts[i]),
      peak_end = as_hms(peak_end[i]),
      baseline = baseline,
      area_under_peak = area
    )
  }
  return(do.call("rbind", output))
}
