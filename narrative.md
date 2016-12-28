Dec 27th
Adding Commit table and logging so we can benchmark our requests. Added logging to rake tasks and installed httplog to benchmark request speeds and amounts.

Dec 27th 
We decided that in order to scale in an interesting way we need to harvest data in as near real time as possible. The only meaninful data that is often updated is commits. The project has three major processes:
1. Scrape Ruby Gems
2. Scrape Users
3. Poll commits to track 'user of the day'

Bottleneck is number of requests per hour allowed by Github. If we can push that up we can get closer to real time data extraction.

Dec 27th
Adding contributors count for each gem so we can estimate number of requests needed every polling period.

Dec 27th
Hitting Github 300 times continuously results in a 429 (too many requests). If we can do a request a second then we are making 60 requests a minute or 3600 an hour. Somewhere in this ballpark. This is a major problem. How can we get around this?

Dec 27th
Problem with scraper. 94,000 duplicates of temparature gem. Was considering running ruby gems scraper massively in parrallel. Realized--duh--ruby gems provides the top 100 gems to us. Created scraper for top 100 gems path. This should speed up iteration speed and debugging. 

Dec 27th
Running into 429 issues. Concerned about number of requests needed to make project successful.