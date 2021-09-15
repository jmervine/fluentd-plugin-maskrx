require 'bundler/setup'
require 'test/unit'
require 'pry'

$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))
$LOAD_PATH.unshift(__dir__)
require 'fluent/test'
require 'fluent/test/helpers'
