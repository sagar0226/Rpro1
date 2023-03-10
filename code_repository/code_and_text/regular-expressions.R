#' # Regular Expressions 
#' 
#' Many word processing programs like Microsoft Word or Google Docs let you search for a pattern - usually a word or phrase - and it will show you where on the page that pattern appears. It also lets you replace that word or phrase with something new. R does the same using the function `grep()` to search for a pattern and tell you where in the data it appears, and `gsub()` which lets you search for a pattern and then replace it with a new pattern.
#' 
#'   * `grep()` - Find
#'   * `gsub()` - Find and Replace
#' 
#' The `grep()` function lets you find a pattern in the text and it will return a number saying which element has the pattern (in a data.frame this tells you which row has a match). `gsub()` lets you input a pattern to find and a pattern to replace it with, just like Find and Replace features elsewhere. You can remember the difference because `gsub()` has the word "sub" in it and what it does is **sub**stitute text with new text. 
#' 
#' A useful cheat sheet on regular expressions is available [here](https://www.rstudio.com/wp-content/uploads/2016/09/RegExCheatsheet.pdf).
#' 
#' For this lesson we will use a vector of 50 crime categories. These are all of the crimes in San Francisco Police data. As we'll see, there are some issues with the crime names that we need to fix.
#' 
## -----------------------------------------------------------------------------------------------------------------
crimes <- c(
  "Arson",
  "Assault",                                  
  "Burglary",                                 
  "Case Closure",                             
  "Civil Sidewalks",                          
  "Courtesy Report",                          
  "Disorderly Conduct",                       
  "Drug Offense",                             
  "Drug Violation",                           
  "Embezzlement",                             
  "Family Offense",                           
  "Fire Report",                              
  "Forgery And Counterfeiting",               
  "Fraud",                                    
  "Gambling",                                 
  "Homicide",                                 
  "Human Trafficking (A), Commercial Sex Acts",
  "Human Trafficking, Commercial Sex Acts",   
  "Juvenile Offenses",                        
  "Larceny Theft",                            
  "Liquor Laws",                              
  "Lost Property",                            
  "Malicious Mischief",                       
  "Miscellaneous Investigation",              
  "Missing Person",                           
  "Motor Vehicle Theft",                      
  "Motor Vehicle Theft?",                     
  "Non-Criminal",                             
  "Offences Against The Family And Children", 
  "Other",                                    
  "Other Miscellaneous",                      
  "Other Offenses",                           
  "Prostitution",                             
  "Rape",                                     
  "Recovered Vehicle",                        
  "Robbery",                                  
  "Sex Offense",                              
  "Stolen Property",                          
  "Suicide",                                  
  "Suspicious",                               
  "Suspicious Occ",                           
  "Traffic Collision",                        
  "Traffic Violation Arrest",                 
  "Vandalism",                                
  "Vehicle Impounded",                        
  "Vehicle Misplaced",                        
  "Warrant",                                  
  "Weapons Carrying Etc",                     
  "Weapons Offence",                          
  "Weapons Offense"
)

#' 
#' When looking closely at these crimes it is clear that some may overlap in certain categories such as theft, and there are several duplicates with slight differences in spelling. For example the last two crimes are "Weapons Offence" and "Weapons Offense". These should be the same crime but the first one spelled "offense" wrong. And take a look at "motor vehicle theft". There are two crimes here because one of them adds a question mark at the end for some reason. 
#' 
#' ## Finding patterns in text with `grep()`
#' 
#' We'll start with `grep()` which allows us to search a vector of data (in R, columns in a data.frame operate the same as a vector) and find where there is a match for the pattern we want to look for. 
#' 
#' The syntax for `grep()` is 
#' 
#' `grep("pattern", data)`
#' 
#' Where pattern is the pattern you are searching for, such as "a" if you want to find all values with the letter a. The pattern must always be in quotes. data is a vector of strings (such as *crimes* we made above or a column in a data.frame) that you are searching in to find the pattern. 
#' 
#' The output of this function is a number which says which element(s) in the vector the pattern was found in. If it returns, for example, the numbers 1 and 3 you know that the first and third element in your vector has the pattern - and that no other elements do. It is essentially returning the index where the conditional statement "is this pattern present" is true.
#' 
#' So since our data is *crimes* our `grep()` function will be `grep("", crimes)`. What we put in the "" is the pattern we want to search for.
#' 
#' Let's start with the letter "a".
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("a", crimes)

#' 
#' It gives us a bunch of numbers where the letter "a" is present in that element of *crimes*. This is useful for subsetting. We can use `grep()` to find all values that match a pattern we want and subset to keep just those values. 
#' 
## -----------------------------------------------------------------------------------------------------------------
crimes[grep("a", crimes)]

#' 
#' Searching for the letter "a" isn't that useful. Let's say we want to subset the data to only include theft related crimes. From reading the list of crimes we can see there are multiple theft crimes - "Larceny Theft", "Motor Vehicle Theft", and "Motor Vehicle Theft?". We may also want to include "Stolen Property" in this search but we'll wait until later in this lesson for how to search for multiple patterns. Since those three crimes all have the word "Theft" in the name we can search for that pattern and it will return only those crimes.
#'  
## -----------------------------------------------------------------------------------------------------------------
grep("Theft", crimes)

#' 
## -----------------------------------------------------------------------------------------------------------------
crimes[grep("Theft", crimes)]

#' 
#' A very useful parameter in `grep()` is `value`. When we set `value` to TRUE, it will print out the actual strings that are a match rather than the element number. While this prevents us from using it to subset (since R no longer knows which rows are a match), it is an excellent tool to check if the `grep()` was successful as we can visually confirm it returns what we want. When we start to learn about special characters which make the patterns more complicated, this will be important.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("Theft", crimes, value = TRUE)

#' 
#' Note that `grep()` (and `gsub()`) is case sensitive so you must capitalize properly.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("theft", value = TRUE, crimes)

#' 
#' Setting the parameter `ignore.case` to be TRUE makes `grep()` ignore capitalization.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("theft", crimes, value = TRUE, ignore.case = TRUE)

#' 
#' If we want to find values which do *not* match with "theft", we can set the parameter `invert` to TRUE.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("theft", crimes, value = TRUE, ignore.case = TRUE, invert = TRUE)

#' 
#' ## Finding and replacing patterns in text with `gsub()`
#' 
#' `gsub()` takes patterns and replaces them with other patterns. An important use in criminology for `gsub()` is to fix spelling mistakes in the text such as the way "offense" was spelled wrong in our data. This will be a standard part of your data cleaning process and is important as a misspelled word can cause significant issues. For example if our previous example of marijuana legalization in Colorado had half of agencies misspelling the name "Colorado", aggregating the data by the state (or simply subsetting to just Colorado agencies) would give completely different results as you'd lose half your data.
#' 
#' `gsub()` is also useful when you want to take subcategories and change the value to larger categories. For example we could take any crime with the word "Theft" in it and change the whole crime name to "Theft". In our data that would take 3 subcategories of thefts and turn it into a larger category we could aggregate to. This will be useful in city-level data where you may only care about a certain type of crime but it has many subcategories that you need to aggregate.
#' 
#' The syntax of `gsub()` is similar to `grep()` with the addition of a pattern to replace the pattern we found.
#' 
#' `gsub("find_pattern", "replace_pattern", data)`
#' 
#' Let's start with a simple example of finding the letter "a" and replacing it with "z". Our data will be the word "cat".
#' 
## -----------------------------------------------------------------------------------------------------------------
gsub("a", "z", "cat")

#' 
#' Like `grep()`, `gsub()` is case sensitive and has the parameter `ignore.case` to ignore capitalization.
#' 
## -----------------------------------------------------------------------------------------------------------------
gsub("A", "z", "cat")

#' 
## -----------------------------------------------------------------------------------------------------------------
gsub("A", "z", "cat", ignore.case = TRUE)

#' 
#' `gsub()` returns the same data you input but with the pattern already replaced. Above you can see that when using capital A, it returns "cat" unchanged as it never found the pattern. When `ignore.case` was set to TRUE it returned "czt" as it then matched to letter "A".
#' 
#' We can use `gsub()` to replace some issues in the crimes data such as "Offense" being spelled "Offence".
#' 
## -----------------------------------------------------------------------------------------------------------------
gsub("Offence", "Offense", crimes)

#' 
#' A useful pattern is an empty string "" which says replace whatever the find_pattern is with nothing, deleting it. Let's delete the letter "a" (lowercase only) from the data. 
#' 
## -----------------------------------------------------------------------------------------------------------------
gsub("a", "", crimes)

#' 
#' ## Useful special characters
#' 
#' So far, we have just searched for a single character or word and expected a return only if an exact match was found. Now we'll discuss a number of characters called "special characters" that allow us to make more complex `grep()` and `gsub()` pattern searches. 
#' 
#' ### Multiple characters `[]`
#' 
#' To search for multiple matches we can put the pattern we want to search for inside square brackets `[]` (note that we use the same square brackets for subsetting but they operate very differently in this context). For example, we can find all the crimes that contain the letters "x", "y", or "z". 
#' 
#' The `grep()` searches if any of the letters inside of the `[]` are present in our *crimes* vector.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("[xyz]", crimes, value = TRUE)

#' 
#' As it searches for any letter inside of the square brackets, the order does not matter.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("[zyx]", crimes, value = TRUE)

#' 
#' This also works for numbers though we do not have any numbers in the data.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("[01234567890]", crimes, value = TRUE)

#' 
#' If we wanted to search for a pattern, such as vowels, that is repeated we could put multiple `[]` patterns together. We will see another way to search for a repeated pattern soon. 
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("[aeiou][aeiou][aeiou]", crimes, value = TRUE)

#' 
#' Inside the `[]` we can also use the dash sign `-` to make intervals between certain values. For numbers, n-m means any number between n and m (inclusive). For letters, a-z means all lowercase letters and A-Z means all uppercase letters in that range (inclusive). 
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("[x-z]", crimes, value = TRUE)

#' 
#' ### n-many of previous character `{n}`
#' 
#' `{n}` means the preceding item will be matched exactly n times.
#' 
#' We can use it to rewrite the above `grep()` to say the values in the `[]` should be repeated three times. 
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("[aeiou]{3}", crimes, value = TRUE)

#' 
#' ### n-many to m-many of previous character `{n,m}`
#' 
#' While `{n}` says "the previous character (or characters inside a `[]`) must be present exactly n times", we can allow a range by using `{n,m}`. Here the previous character must be present between n and m times (inclusive).
#' 
#' We can check for values where there are 2-3 vowels in a row. Note that there cannot be a space before or after the comma.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("[aeiou]{2,3}", crimes, value = TRUE)

#' 
#' If we wanted only crimes with exactly three vowels in a row we'd use `{3,3}`.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("[aeiou]{3,3}", crimes, value = TRUE)

#' 
#' 
#' If we leave n blank, such as `{,m}` it says, "previous character must be present up to m times." 
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("[aeiou]{,3}", crimes, value = TRUE)

#' 
#' This returns every crime as "up to m times" includes zero times.
#' 
#' And the same works for leaving m blank but it will be "present at least n times". 
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("[aeiou]{3,}", crimes, value = TRUE)

#' 
#' ### Start of string 
#' 
#' The `^` symbol (called a caret) signifies that what follows it is the start of the string. We put the `^` at the beginning of the quotes and then anything that follows it must be the very start of the string. As an example let's search for "Family". Our data has both the "Family Offense" crime and the "Offences Against The Family And Children" crime (which likely are the same crime written differently). If we use `^` then we should only have the first one returned.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("^Family", crimes, value = TRUE)

#' 
#' ### End of string `$`
#' 
#' The dollar sign `$` acts similar to the caret `^` except that it signifies that the value before it is the **end** of the string. We put the `$` at the very end of our search pattern and whatever character is before it is the end of the string. For example,  let's search for all crimes that end with the word "Theft".
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("Theft$", crimes, value = TRUE)

#' 
#' Note that the crime "Motor Vehicle Theft?" doesn't get selected as it ends with a question mark.
#' 
#' ### Anything `.`
#' 
#' The `.` symbol is a stand-in for any value. This is useful when you aren't sure about every part of the pattern you are searching. It can also be used when there are slight differences in words such as our incorrect "Offence" and "Offense". We can replace the "c" and "s" with the `.`.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("Weapons Offen.e", crimes, value = TRUE)

#' 
#' ### One or more of previous `+`
#' 
#' The `+` means that the character immediately before it is present at least one time. This is the same as writing `{1,}`. If we wanted to find all values with only two words, we would start with some number of letters followed by a space followed by some more letters and the string would end.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("^[A-Za-z]+ [A-Za-z]+$", crimes, value = TRUE)

#' 
#' ### Zero or more of previous `*`
#' 
#' The `*` special character says match zero or more of the previous character and is the same as `{0,}`. Combining `.` with `*` is powerful when used in `gsub()` to delete text before or after a pattern. Let's write a pattern that searches the text for the word "Weapons" and then deletes any text after that. 
#' 
#' Our pattern would be "Weapons.*" which is the word "Weapons" followed by anything zero or more times. 
#' 
## -----------------------------------------------------------------------------------------------------------------
gsub("Weapons.*", "Weapons", crimes)

#' 
#' And now our last three crimes are all the same. 
#' 
#' ### Multiple patterns `|`
#' 
#' The vertical bar `|` special character allows us to check for multiple patterns. It essentially functions as "pattern A or Pattern B" with the `|` symbol replacing the word "or" (and making sure to not have any space between patterns.). To check our crimes for the word "Drug" or the word "Weapons" we could write "Drug|Weapon" which searches for "Drug" or "Weapons" in the text. 
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("Drug|Weapons", crimes, value = TRUE)

#' 
#' ### Parentheses `()`
#' 
#' Parentheses act similar to the square brackets `[]` where we want everything inside but with parentheses the values must be in the proper order.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("(Offense)", crimes, value = TRUE)

#' 
#' Running the above code returns the same results as if we didn't include the parentheses. The usefulness of parentheses comes when combining it with the `|` symbol to be able to check "(X|Y) Z"), which says, "look for either X or Y which must be followed by Z". 
#' 
#' Running just "(Offense)" returns values for multiple types of offenses. Let's say we just care about Drug and Weapon Offenses. We can search for "Offense" normally and combine `()` and `|` to say, "search for either the word 'Drug' or the word 'Family' and they should be followed by the word 'Offense'."
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("(Drug|Weapons) Offense", crimes, value = TRUE)

#' 
#' ###  Optional text `?`
#' 
#' The question mark indicates that the character immediately before the `?` is optional.
#' 
#' Let's search for the term "offens" and add a ? at the end. This says search for the pattern "offen" and we expect an exact match for that pattern. And if the letter "s" follows "offen" return that too, but it isn't required to be there. 
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("Offens?", crimes, value = TRUE)

#' 
#' We can further combine it with `()` and `|` to get both spellings of Weapon Offense.
#' 
## -----------------------------------------------------------------------------------------------------------------
grep("(Drug|Weapons) Offens?", crimes, value = TRUE)

#' 
#' ## Changing capitalization
#' 
#' If you're dealing with data where the only difference is capitalization (as is common in crime data) instead of using `gsub()` to change individual values, you can use the functions `toupper()` and `tolower()` to change every letter's capitalization. These functions take as an input a vector of strings (or a column from a data.frame) and return those strings either upper or lowercase.
#' 
## -----------------------------------------------------------------------------------------------------------------
toupper(crimes)

#' 
## -----------------------------------------------------------------------------------------------------------------
tolower(crimes)

#' 
