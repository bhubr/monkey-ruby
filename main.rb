require 'etc'
require_relative './repl'

user = Etc.getlogin
print "Hello #{user}! This is the Monkey programming language!\n"
print "Feel free to type in commands\n"
start_repl

