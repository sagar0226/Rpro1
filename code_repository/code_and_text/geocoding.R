#' # Geocoding 
#' 
## ----include = FALSE--------------------------------------------------------------------------------
if (!knitr:::is_html_output()) {
  options("width" = 56)
  knitr::opts_chunk$set(tidy.opts = list(width.cutoff = 56, indent = 2), tidy = TRUE)
  }

#' 
#' For this chapter you'll need the following file, which is available for download [here](https://github.com/jacobkap/r4crimz/tree/master/data): san_francisco_active_marijuana_retailers.csv.
#' 
#' Several recent studies have looked at the effect of marijuana dispensaries on crime around the dispensary. For these analyses they find the coordinates of each crime in the city and see if it occurred in a certain distance from the dispensary. Many crime data sets provide the coordinates of where each occurred, however sometimes the coordinates are missing - and other data such as marijuana dispensary locations give only the address - meaning that we need a way to find the coordinates of these locations.
#' 
#' ## Geocoding a single address
#' 
#' In this chapter we will cover how to geocode addresses. Geocoding is the process of taking an address (e.g. 123 Main Street, Somewhere, CA, 12345) and getting the longitude and latitude coordinates of that address. With these coordinates we can then do spatial analyses on the data ranging from simply making a map and showing where each address is to merging these coordinates with some other spatial data (such as seeing which police district the address is in) and seeing how it relates to other variables, such as crime.
#' 
#' To do our geocoding, we're going to use the package `tidygeocoder` which greatly simplifies the work of geocoding addresses in R. For more information about this package, please see the package's site [here](https://jessecambon.github.io/tidygeocoder/). If you've never used this package before you'll need to install it using `install.packages("tidygeocoder")`
#' 
## ----eval = FALSE-----------------------------------------------------------------------------------
## install.packages("tidygeocoder")

#' 
#' 
#' Now we need to tell R that we want to use this package by running `library(tidygeocoder)`.
#' 
## ---------------------------------------------------------------------------------------------------
library(tidygeocoder)

#' 
#' To geocode our addresses we'll use the helpfully named `geocode()` function inside of `tidygeocoder`. For `geocode()` we input an address and it returns the coordinates for that address. For our address we'll use "750 Race St. Philadelphia, PA 19106" which is the address of the Philadelphia Police Department headquarters.
#' 
## ---- error = TRUE----------------------------------------------------------------------------------
geocode("750 Race St. Philadelphia, PA 19106")

#' As shown above, running `geocode("750 Race St. Philadelphia, PA 19106")` gives us an error that tells us that ".tbl is not a dataframe." The issue is that `geocode()` expects a data.frame (and .tbl is an abbreviation for tibble which is a kind of data.frame), but we entered only the string with our one address, not a data.frame. For this function to work we need to enter two parameters into `geocode()`: a data.frame (or something similar such as a tibble) and the name of the column which has the addresses.^[We can look at all of the parameters for this function by running the code `help(geocode)` or `?geocode()` to look at the functions Help page.] Since we need a data.frame, we'll make one below. I'm calling it `address_to_geocode` and calling the column with the address "address", but you can call both the data.frame and the column whatever name you want. 
#' 
## ---------------------------------------------------------------------------------------------------
address_to_geocode <- data.frame(address = "750 Race St. Philadelphia, PA 19106")

#' 
#' Now let's try again. We'll enter our data.frame `address_to_geocode` first and then the name of our column which is "address".
#' 
## ---------------------------------------------------------------------------------------------------
geocode(address_to_geocode, address)

#' 
#' It worked, returning the same data.frame but with two additional columns with the latitude and longitude of that address.
#' 
#' You might be wondering why we put "address" into `geocode()` without quotes when usually when we talk about a column we need to do so in quotes. The simple answer is that the authors of the `tidygeocoder` package spent the time allowing users to input the column name either with or without quotes. Trying it again and now having "address" in quotes gives us the same result.
#' 
## ---------------------------------------------------------------------------------------------------
geocode(address_to_geocode, "address")

#' 
#' There are two additional parameters which are important to talk about for this function, especially when you encounter an address not geocoding. 
#' 
#' First, there are actually multiple sources where you can enter an address and get the coordinates for that address. Just think about the big mapping apps or sites, such as Google Maps and Apple Maps. For these sources you can enter in the same address and you'll get different results. In most cases you'll get extremely similar coordinates, usually off only after a few decimals points, so they are functionally identical. But occasionally you'll have some addresses that can be geocoded through some sources but not others. This is because some sources have a more comprehensive list of addresses than others. 
#' 
#' At the time of this writing the `tidygeocoder` package can handle geocoding from 13 different sources. For 10 of these, however, you need to setup an API key and some also require paying money (usually after a set number of addresses that it'll geocode for free each day). So here I'll just cover the three sources of geocoding that don't require any setup: "osm" (Open Street Map or OSM is similar to Google Maps), "census" (the US Census Bureau's geocoder), and "arcgis" (ArcGIS is a clunky mapping software that nonetheless has an excellent geocoder that R can use). To select which of these to use ("osm" is the default), you add the parameter "method" and set that equal to which one you want to use. As "osm" is the default we actually don't need to set it explicitly, but we'll do so anyways here as an example of the three geocoding sources we want to use.
#' 
## ---------------------------------------------------------------------------------------------------
geocode(address_to_geocode, "address", method = "osm")

#' 
## ---------------------------------------------------------------------------------------------------
geocode(address_to_geocode, "address", method = "census")

#' 
## ---------------------------------------------------------------------------------------------------
geocode(address_to_geocode, "address", method = "arcgis")

#' 
#' If you compare the longitude and latitudes from these three sources you'll notice that they're all different but only slightly so. By default this function returns a tibble instead of a normal data.frame so it only shows one decimal point by default - though it doesn't actually round the number, merely shorten what it shows us. We can change the output back into a data.frame by using the `data.frame()` function. 
#' 
## ---------------------------------------------------------------------------------------------------
example <- geocode(address_to_geocode, "address", method = "arcgis")
example <- data.frame(example)
example

#' 
#' Given how similar the coordinates are, you really only need to set the source of the geocoder in cases where one geocoder fails to find a match for the address. 
#' 
#' The second important parameter is `full_results` which is by default set to FALSE. When set to TRUE it gives more columns in the returning data.frame than just the longitude and latitude of that address. These columns differ for each geocoder source so we'll look at all three.
#' 
## ---------------------------------------------------------------------------------------------------
geocode(address_to_geocode, "address", method = "osm", full_results = TRUE)

#' 
#' For OSM as a source we also get information about the address such as what type of place it is, a bounding box which is a geographic area right around this coordinate, the address for those coordinates in the OSM database, and a bunch of other variables that don't seem very useful for our purposes such as the "importance" of the address. It's interesting that OSM classifies this address as a "house" as the police headquarters for a major police department is quite a bit bigger than a house, so this is likely an misclassification of the type of address. The most important extra variable here is the address, called the "display_name". 
#' 
#' Sometimes geocoders will be quite a bit off in their geocoding because they match the address you inputted incorrectly to one in their database. For example, if you input "123 Main Street" and the geocoder thinks you mean "123 Maine Street" you may be quite a bit off in the resulting coordinates. When you only get coordinates returns you won't know that the coordinates are wrong. Even if you know where an address is supposed to be it's hard to catch errors like this. If you're geocoding addresses in a single city and one point is in a different city (or completely different part of the world), then it's pretty clear that there's an error. But if the coordinates are simply in a wrong part of the city, but near other coordinates, then it's very hard to notice a problem. So having an address to check against the one you inputted is a very useful way of validate the geocoding. 
#' 
## ---------------------------------------------------------------------------------------------------
geocode(address_to_geocode, "address", method = "census", full_results = TRUE)

#' 
#' These results are similar to the OSM results and also have the matched address to compare your inputted address to. Most of the columns are just the address broken into different pieces (street, city, state, etc.) so are mostly repeating the address again in multiple columns. 
#' 
## ---------------------------------------------------------------------------------------------------
geocode(address_to_geocode, "address", method = "arcgis", full_results = TRUE)

#' 
#' For the ArcGIS results we have the matched address again, and then an important variable called "score" which is basically a measure of how confidence ArcGIS is that it matched the right address. Higher values are more confidence, but in my experience anything under 90-95 confidence is an incorrect address. These results also repeat the longitude and latitude columns as "location.x" and "location.y" columns, and I'm not sure why they do so. 
#' 
#' ## Geocoding San Francisco marijuana dispensary locations
#' 
#' So now that we can use the `geocoder()` function well, we can geocode every location in our marijuana dispersary data.
#' 
#' Let's read in the marijuana dispensary data which is called "san_francisco_active_marijuana_retailers.csv" and call the object *marijuana*. Note the "data/" part in front of the name of the .csv file. This is to tell R that the file we want is in the "data" folder of our working directory. Doing this is essentially a shortcut to changing the working directory directly.
#' 
## ---------------------------------------------------------------------------------------------------
library(readr)
marijuana <- read_csv("data/san_francisco_active_marijuana_retailers.csv")
marijuana <- as.data.frame(marijuana)

#' 
#' Let's look at the top 6 rows. 
#' 
## ---------------------------------------------------------------------------------------------------
head(marijuana)

#' 
#' So the column with the address is called *Premise Address*. Since it's easier to deal with columns that don't have spacing in the name, we will be using `gsub()` to remove spacing from the column names. Each address also ends with "County:" followed by that address's county, which in this case is always San Francisco. That isn't normal in an address so it may affect our geocode. We need to `gsub()` that column to remove that part of the address.
#' 
## ---------------------------------------------------------------------------------------------------
names(marijuana) <- gsub(" ", "_", names(marijuana))

#' 
#' Since the address issue is always " County: SAN FRANCISCO" we can just `gsub()` out that entire string.
#'  
## ---------------------------------------------------------------------------------------------------
marijuana$Premise_Address <- gsub(" County: SAN FRANCISCO", "", marijuana$Premise_Address)

#' 
#' Now let's make sure we did it right.
#' 
## ---------------------------------------------------------------------------------------------------
names(marijuana)
head(marijuana$Premise_Address)

#' To do the geocoding we'll just tell `geocode` our data.frame name and the name of the column with the addresses. We'll save the results back into the `marijuana` object. As noted earlier, we don't need to put the name of our column in quotes, but I like to do so because it is consistent with some other functions that require it. Running this code may take up to a minute because it's geocoding 33 different addresses.
#' 
## ---------------------------------------------------------------------------------------------------
marijuana <- geocode(marijuana, "Premise_Address")

#' 
#' Now it appears that we have longitude and latitude for every dispensary. We should check that they all look sensible.
#' 
## ---------------------------------------------------------------------------------------------------
summary(marijuana$long)

#' 
## ---------------------------------------------------------------------------------------------------
summary(marijuana$lat)

#' The minimum and maximum are very similar to each other for both longitude and latitude so that's a sign that it geocoded correctly. The 10 NA values mean that it didn't find a match for 10 of the addresses. Let's try again and now set `method` to "arcgis" which generally has a very high match rate. Before we do this let's just remove the entire latitude and longitude columns from our data. How the `geocode()` function works is that if we keep the "long" and "lat" columns that are currently in the data from when we just geocoded, when we run it again it'll make new columns that have nearly identical names. We usually want as few columns in our data as possible so there's no point having the "lat" column from the last geocode run with the 10 NAs and another "lat" (though slightly different, automatically chosen name) column from this time we run `geocode().` 
#' 
#' We could also just geocode the 10 addresses that failed on the first run, but given that we'll only geocoding a small number of addresses it won't take much extra time to have ArcGIS run it all. Running this function on just the NA rows requires a bit more work than just rerunning them all. In general, when the choice is between you spending time writing code and letting the computer do more work, let the computer do the work. And in general I'd recommend starting with ArcGIS as it is more reliable for geocoding. We'll remove the current coordinate columns by setting them each to NULL.
#' 
## ---------------------------------------------------------------------------------------------------
marijuana$long <- NULL
marijuana$lat  <- NULL
marijuana      <- geocode(marijuana, "Premise_Address", method = "arcgis")

#' And let's do the `summary()` check again. 
#' 
## ---------------------------------------------------------------------------------------------------
summary(marijuana$long)

#' 
## ---------------------------------------------------------------------------------------------------
summary(marijuana$lat)

#' No more NAs which means that we successfully geocoded our addresses. Another check is to make a simple scatterplot of the data. Since all the data is from San Francisco, they should be relatively close to each other. If there are dots far from the rest, that is probably a geocoding issue.
#' 
## ---------------------------------------------------------------------------------------------------
plot(marijuana$long, marijuana$lat)

#' 
#' Most points are within a very narrow range so it appears that our geocoding worked properly. 
#' 
#' To finish this lesson we want to save the *marijuana* data.frame. We'll use the `write_csv()` function from the `readr` package to save it as a .csv file. Since this data is now geocoded and it is specifically for San Francisco, we'll save it as "san_francisco_marijuana_geocoded.csv".
#' 
## ---------------------------------------------------------------------------------------------------
write_csv(marijuana, file = "data/san_francisco_marijuana_geocoded.csv")
