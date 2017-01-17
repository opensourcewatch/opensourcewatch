# How to Debug Servers With Daemons

The following are a few typical steps you should take when trying to get the different nodes to work with the centralized cli interface.

Why? Repeating the same steps when debugging the servers is not uncommon, but without a standardized process you tend to forget the separate steps and it may lead to wasting more time than needed.

1. Check /etc/ssh/sshd_config. Does it PermitUserEnvironment? Is it spelled correctly?

2. Check ~/.ssh/environment. Does it have the env variables?

3. Make sure to restart the ssh service.

4. It's probably a good time to restart the node if you have tried to run any other tasks that may be conflicting with the on  you're trying to run.

5. Check application.yml. Does it have the proper ENV variables for figaro or other environment variable service being used?

  a. If the environment variables are stored, then you should have no problem running the `rake dispatch:*` tasks. Check if the task that you are running even works.
