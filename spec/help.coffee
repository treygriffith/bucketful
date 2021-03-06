should = require 'should'
jscov = require 'jscov'
help = require jscov.cover('..', 'src', 'implementation/help')
{createStream} = require './util/stringstream'

describe 'help', ->

  describe 'binaryMeta', ->

    it 'produces the expected help text when given the first arg "help"', (done) ->
      stream = createStream()
      help.binaryMeta('help', stream, ->)
      stream.toString().should.eql '''
        Deploys websites to Amazon S3

        Options:
          --source       Directory to use as starting point for the upload
          --bucket       S3 bucket used as target for the upload
          --key          AWS access key
          --secret       AWS access secret
          --region       AWS region to create the bucket in (defaults to 'us-east-1')
          --index        File to use as index page (defaults to 'index.html')
          --error        File to use as error page
          --dns          The name of a bucketful plugin for configuring a CNAME
          --configs      Configuration files (defaults to 'package.json;config.json')
          --version, -v  Print the current version number
          --help, -h     Show this help message


      '''
      done()


    it 'prints the current version when given the string "version"', (done) ->
      stream = createStream()
      help.binaryMeta('version', stream, ->)
      version = require('../package.json').version
      dots = Array::filter.call(version, (x) -> x == '.')
      dots.should.have.length 2
      stream.toString().should.eql(version + '\n')
      done()


    it 'runs the callback and does nothing else when given the string "version"', (done) ->
      ran = false
      stream = createStream()
      help.binaryMeta(null, stream, -> ran = true)
      stream.toString().should.eql ''
      ran.should.eql true
      done()
