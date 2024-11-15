# Load the dataset
library(readr)
library(ggplot2)
library(dplyr)
library(tidyr)

IPL <- read_csv("C:/Users/chand/Downloads/IPL.csv")
View(IPL)

#data cleaning
# Check structure and summary
str(IPL)
summary(IPL)
# Check for missing values
colSums(is.na(IPL))
# View the first few rows to identify potential issues
head(IPL)

# Fill missing values in `city` with the most frequent value (mode)
mode_city <- names(sort(table(IPL$city), decreasing = TRUE))[1]
IPL$city[is.na(IPL$city)] <- mode_city

# For `player_of_match` and `winner`, use "Unknown" or leave as NA
IPL$player_of_match[is.na(IPL$player_of_match)] <- "Unknown"
IPL$winner[is.na(IPL$winner)] <- "Unknown"

# Fill with the mean
IPL$result_margin[is.na(IPL$result_margin)] <- mean(IPL$result_margin, na.rm = TRUE)
IPL$target_runs[is.na(IPL$target_runs)] <- mean(IPL$target_runs, na.rm = TRUE)
IPL$target_overs[is.na(IPL$target_overs)] <- mean(IPL$target_overs, na.rm = TRUE)

# Drop the `method` column
IPL <- IPL %>% select(-method)

# Check for remaining missing values
colSums(is.na(IPL))

# View a summary of the updated dataset
summary(IPL)
dim(IPL)

#Questions
# 1. How many wins did each team achieve across different seasons?
ggplot(ipl_data, aes(x = season, fill = winner)) +
  geom_bar(position = "dodge") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "Win Distribution by Season", x = "Season", y = "Number of Wins")

#2. Who are the top 10 players in terms of 'Player of the Match' awards?
top_players <- ipl_data %>%
  count(player_of_match, sort = TRUE) %>%
  head(10)
ggplot(top_players, aes(x = reorder(player_of_match, n), y = n)) +
  geom_bar(stat = "identity", fill = "darkblue") +  # Fixed the 'stat' argument
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "Top 10 Players with 'Player of the Match' Awards", 
       x = "Player", 
       y = "Number of Awards")

#3. Is there a correlation between winning the toss and winning the match?
ggplot(ipl_data, aes(x = toss_winner == winner)) +
  geom_bar(fill = "lightblue") +
  labs(title = "Correlation between Toss Win and Match Win", x = "Toss Winner = Match Winner", y = "Frequency")

#4.Who played maximum super overs?
superover_matches <- ipl_data %>%
  filter(super_over == "Y")

# Count occurrences of each team in both 'team1' and 'team2' columns
teams_superovers <- superover_matches %>%
  pivot_longer(cols = c(team1, team2), names_to = "role", values_to = "team") %>%
  count(team, sort = TRUE)

# Plot the results
ggplot(teams_superovers, aes(x = n, y = reorder(team, n), fill = team)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Teams with Most Super Overs Played",
    x = "Number of Super Overs",
    y = "Teams"
  ) +
  theme_minimal() +
  theme(legend.position = "none") +
  scale_fill_brewer(palette = "Set3")

#5. What is the relationship between target runs and result margin?
ggplot(ipl_data, aes(x = target_runs, y = result_margin)) +
  geom_point(color = "blue") +
  labs(title = "Relationship between Target Runs and Result Margin", x = "Target Runs", y = "Result Margin")

#6.How do total runs vary seasonally across the dataset?
seasonal_runs <- ipl_data %>% group_by(season) %>% summarize(total_runs = sum(target_runs, na.rm = TRUE))
ggplot(seasonal_runs, aes(x = season, y = total_runs, group = 1)) +
  geom_line(color = "red") +
  labs(title = "Seasonal Variation in Total Runs", x = "Season", y = "Total Runs")

#7. How does team performance change over different seasons?
ggplot(ipl_data, aes(x = season, fill = winner)) +
  geom_bar() +
  labs(title = "Team Performance Across Seasons", x = "Season", y = "Number of Wins")

#8.Are there any notable trends in the winning margin by team?
ggplot(ipl_data, aes(x = winner, y = result_margin)) +
  geom_boxplot(fill = "lightgreen") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "Win Margin by Team", x = "Team", y = "Win Margin")

#9.What is the relationship between toss winner and match winner by season?
ggplot(ipl_data, aes(x = season, fill = toss_winner == winner)) +
  geom_bar(position = "dodge") +
  labs(title = "Relationship between Toss Winner and Match Winner by Season", x = "Season", y = "Frequency")

#10.Which team had the highest average win margin over all seasons?
avg_win_margin <- ipl_data %>% group_by(winner) %>% summarize(avg_margin = mean(result_margin, na.rm = TRUE))
ggplot(avg_win_margin, aes(x = reorder(winner, avg_margin), y = avg_margin)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(title = "Average Win Margin by Team", x = "Team", y = "Average Win Margin")

#11. What is the average win margin by match type?
ggplot(ipl_data, aes(x = match_type, y = result_margin)) +
  geom_bar(stat = "summary", fun = "mean", fill = "violet") +
  labs(title = "Average Win Margin by Match Type", x = "Match Type", y = "Average Win Margin")

#12.Which are top 5 venues for IPL?
top_venues <- as.data.frame(table(ipl_data$venue))
top_venues <- top_venues[order(-top_venues$Freq), ][1:5, ]
colnames(top_venues) <- c("venue", "matches_count")

# Plotting
library(ggplot2)
ggplot(top_venues, aes(x = reorder(venue, -matches_count), y = matches_count)) +
  geom_bar(stat = "identity", fill = "blue") +
  labs(title = "Top 5 Venues with Most IPL Matches",
       x = "Venue",
       y = "Number of Matches") +
  theme_minimal()

#13.Which teams won the most matches batting first or chasing?
bat_first_vs_chase <- ipl_data %>%
  filter(winner != "Unknown") %>%
  count(winner, toss_decision)

ggplot(bat_first_vs_chase, aes(x = winner, y = n, fill = toss_decision)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Matches Won Batting First vs Chasing",
       x = "Team", y = "Number of Wins") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

#14. What is the proportion of matches won by each team?
team_wins <- ipl_data %>%
  filter(winner != "Unknown") %>%
  count(winner) 

ggplot(team_wins, aes(x = "", y = n, fill = winner)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  labs(title = "Proportion of Matches Won by Each Team") +
  theme_void() +
  theme(legend.position = "right")

#15.How does match duration (overs) vary by season?
ggplot(ipl_data, aes(x = season, y = target_overs, fill = season)) +
  geom_violin(trim = FALSE) +
  labs(title = "Variation in Match Duration (Overs) by Season",
       x = "Season", y = "Overs") +
  theme_minimal() +
  theme(legend.position = "none")


#16.What is the distribution of runs scored in matches (target_runs)?

# Histogram for distribution of runs scored in matches
ggplot(IPL, aes(x = target_runs)) +
  geom_histogram(binwidth = 10, fill = "forestgreen", color = "black") +
  labs(title = "Distribution of Runs Scored in Matches",
       x = "Target Runs",
       y = "Frequency") +
  theme_minimal()

#17.What is the relationship between the season and the occurrence of super overs?
# Filter for matches with super overs data
superover_season_table <- table(IPL$season, IPL$super_over)

# Mosaic plot
mosaicplot(superover_season_table,
           main = "Season vs Super Over Occurrence",
           xlab = "Season",
           ylab = "Super Over (Yes/No)",
           color = TRUE,
           las = 2,
           cex.axis = 0.8)  # Adjust axis text size for readability





