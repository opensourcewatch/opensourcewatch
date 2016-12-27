Dec 27th
Hitting Github 300 times continuously results in a 429 (too many requests). If we can do a request a second then we are making 60 requests a minute or 3600 an hour. Somewhere in this ballpark. This is a major problem. How can we get around this?

Dec 27th
Problem with scraper. 94,000 duplicates of temparature gem. Was considering running ruby gems scraper massively in parrallel. Realized--duh--ruby gems provides the top 100 gems to us. Created scraper for top 100 gems path. This should speed up iteration speed and debugging. 

Dec 27th
Running into 429 issues. Concerned about number of requests needed to make project successful.