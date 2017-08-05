# README

This is the monolith for Open Source Watch containing:
* the application code
* the data aggregation processes
* the command and control CLI app

Note: There are a few deprecated scripts under the lib directory. Namely, the log manager and scripts to run the application queries while troubleshooting the app. These will likely be removed in the next release. This was used while troubleshooting throttling by Github and for performance tuning.

## The application code
This is fairly simple, providing a easy to read tabular view for users to peruse the
top 10:
- issues
- commenters
- committers
- repositories

This uses materialized views for fast queries. The app has a single endpoint and delivers some client side Javascript that handles switching between tabs with asynchronous calls.

Every 5 minutes a cron job runs to refresh all matviews. This is done with the whenever gem.

## The data aggregation process

### Step 1: Gather Repos to Track
First we need to find the top 100k to track and periodically update this. This is currently a manual task.

```                        
                            +-------------------+    +----+
  api_tasks.search_repos -> | Github Search API | -> | DB |
                            +-------------------+    +----+
```

This interfaces with the search API searching by stars descending and then paginating through the results, saving each repo to the database. Note that Github's search is not consistent and searching by stars descending and paginating returns incorrect results. The implementation actually modifies the search ie. all repos at 1000 stars, and then paginates through THOSE results.

## Step 2: Score and Create Jobs
Once we have a few hundred thousand repositories we select an arbitrary number to push into our Redis job queue.

This is another rake task:

``` ruby
  redis_tasks.priority_redis_requeue
```

This does two things:
1) score and order repos
2) rangemap (hash) top 100k into 10 redis sub queues

```                                     
                                             +-------------+
                                             | RedisQueue1 |
  +--------------+    +---------------+      +-------------+
  | Repositories | -> | PriorityQueue | ->   | RedisQueue2 |
  +--------------+    +---------------|      +-------------+
                                                    ...
                                             +-------------+
                                             | RedisQueue10|
                                             +-------------+
```

### Step 3: Kickoff
Now that we are all set up, we can finally start to harvest data from Github using the CLI app. First we pull down the latest commits from our repo, then on each node we run a rake task via the CLI app.

```
               +-------+
               | NodeA |
+---------+    +-------+     +-------+
| CLI App | -> | NodeB |  -> | Start |
+---------+    +-------+     +-------+
               | NodeX |
               +-------+
                   ^
                 Github
               Monolithic
                Codebase
```

The CLI app runs scraper rake tasks on a node as a daemon inside an infinite bash loop for failover (in case of a dirty job).

## How Scraping Works

```
+---------+    +------------+    +---------------+        RQ1
| Workers | -> | Dispatcher | -> | PriorityQueue |  ->    RQ2
+---------+    +------------+    +---------------+         ...
                                                          RQ10
```

The dispatcher object sits on each server and handles the fetching of new jobs. It collaborates with a PriorityQueue object that is responsible for knowing which priority (aka redis queue) to grab a job from.

The scraper goes and scrapes the resource and saves fresh data to the database.

# Appendix

## How to Debug Servers With Daemons

The following are a few typical steps you should take when trying to get the different nodes to work with the centralized cli interface.

Why? Repeating the same steps when debugging the servers is not uncommon, but without a standardized process you tend to forget the separate steps and it may lead to wasting more time than needed.

1. Check /etc/ssh/sshd_config. Does it PermitUserEnvironment? Is it spelled correctly?

2. Check ~/.ssh/environment. Does it have the env variables?

3. Make sure to restart the ssh service.

4. It's probably a good time to restart the node if you have tried to run any other tasks that may be conflicting with the on  you're trying to run.

5. Check application.yml. Does it have the proper ENV variables for figaro or other environment variable service being used?

  a. If the environment variables are stored, then you should have no problem running the `rake dispatch:*` tasks. Check if the task that you are running even works.
