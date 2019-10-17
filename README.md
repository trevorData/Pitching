# Which stats best predict the length of a pitching career?

### [Main plot](https://i.imgur.com/QgEb4OH.png)

Looking at a single season for a pitcher, which stats give us the most information about how much longer his career will last?
	
---

Based on single season data from the last 15 years for currently inactive pitchers, min 100 innings pitched.
Y values represent the coefficients obtained from doing simple linear regression on the z score for each of the stats against the years remaining in a pitchers career.

Note that the graph references an "improvement" in each stat (meaning ERA down, K% up, etc). If we measure in terms of *increasing* each stat the graph looks like [this](https://i.imgur.com/KZW27Xh.png)

---

_ | Mean| Std Dev  
---|---|----  
ERA| 4.31| 0.91  
Age| 29.50| 4.60  
Innings Pitched that Season | 169.51| 37.81
Strikeout % | 16.70| 4.17
Walk %| 7.56| 2.10
Win/Loss %| 0.51| 0.13
WHIP | 1.35 | 0.16
Avg Pitches per Inning| 16.06| 0.93
Years Left in Career| 4.42| 2.87

Standard deviation was used instead of real values to give a better idea of how "exceptional" a pitcher needs to be to extend his career longer than average. Remember that 1 std dev above average is the 85th percentile of pitchers and 2 std dev is the 97th percentile

For a better idea of this relationship in terms of real values take a look at these scatter plots:

[ERA](https://i.imgur.com/ImCJK1n.png)  
[Age](https://i.imgur.com/tOKZOW6.png)  
[IP](https://i.imgur.com/CysbBt6.png)  
[K%](https://i.imgur.com/XYORUox.png)  
[BB%](https://i.imgur.com/xTfQAZq.png)  
[WL%](https://i.imgur.com/NqiQCVb.png)  
[WHIP](https://i.imgur.com/C7jvCPh.png)  
[Pit/IP](https://i.imgur.com/d4cp1i6.png)


---

### Predicting career lengths for currently active pitchers

A surprisingly accurate model for career length can be made using only three predictors: Age, Innings Pitched, and W-L%

The model trained here with these three predictors has an RMSE of 2.45 years (think of this as average error of prediction), and actually gets worse when you add in seemingly important stats like ERA. This is probably because there is a high correlation between W-L% and ERA, and any new information added will likely contain a lot of noise.

Here are some predictions made by the model based on performances by pitchers this season:

**Who will retire the soonest?**  

_ | Years Left | Final Age
---|---|---
CC Sabathia | 0.62 |   38.62
Jordan Zimmermann |1.23 |    34.23
Jhoulys Chacin  |  2.01|    33.01
Jason Vargas |   2.05|    38.05
Tommy Milone|  2.11|    34.11

**Who will be around the longest?**

_ | Years Left | Final Age
---|---|---
Eduardo Rodriguez|   6.70   | 32.70
Jack Flaherty| 6.92|    29.92
Walker Buehler|     6.96 |   30.96
Shane Bieber|     7.15 |   31.15
Mike Soroka|     7.64|   28.64

**Who will be the oldest?**

_ | Years Left | Final Age
---|---|---
J.A. Happ|     2.70|    38.70
Charlie Morton|    3.91|    38.91
Zack Greinke|     4.30|    39.30
Adam Wainwright|     2.55|    39.55
Justin Verlander|     4.25|    40.25

---

### Sources:

Data taken from baseball-reference

Analysis/Visualizations done with R using the packages:  
dplyr  
magrittr  
ggplot2  
stringr  

I would have liked to include more detailed data in the model such as avg fastaball speed and pitch selection but this information is not widely available past 2016. If anyone knows good sources for this sort of data please let me know!
