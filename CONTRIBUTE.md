# contributing

thank you for taking interest in this project! here are just a few things to keep in mind if you want to contribute

## adding methods

if you want to add a method, it must be added to the array in the following format to work properly

`command , statement_that_will_return_true_if_we_can_execute_reverse_shell_with_command , syntax_for_reverse_shell?`

- `command` is the command to be ran, not the full path to the command
- the goal with the `statement_that_will_return_true_if_we_can_execute_reverse_shell_with_command` is not to see if we can execute the command but to see if we can make a TCP connection with it. For instance, in some of the methods like Python and Perl, we have to import libraries to handle the connection, so the eval statement checks if we can import those
- the `syntax_for_reverse_shell` portion is simply the code to execute with $RHOST and $RPORT variables
- the `?` at the end of the line is _important_ because it is the IFS for the arrays, also the spaces around the commas are necessary because `awk -F ' , '` is used to split the arrays (some of the methods have commas in the code to the spaces get around that)

## adding doors

if you want to add a door, it must be added to the array in the following format to work properly

`name , eval_and_prep_statement , code_to_run_to_install_the_reverse_shell_in_the_door?`

- spaces, commas, and `?` are the same as the methods
- the name can be anything that gives you an idea of how it was installed
- the `eval_and_prep_statement` serves two functions
	- if it returns true, we can use the door
	- does any necessary prep work for installing, if necessary (e.g. the one for crontab creates a tmp file with the current crontabs so the install code will install those too)
- the spirit of the `code_to_run_to_install_the_reverse_shell_in_the_door` is minimal disruption (e.g. not printing to screen and not interrupting normal processes)
- create an if statement in the cleanup function that enumerates whether or not that door was used to install a reverse shell and if so, remove it. If that door is responsible for other tasks be sure not to disrupt those

## adding features

to add a stand alone feature, please create a new function and call it in `main`
