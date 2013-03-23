AWS = require 'aws-sdk'
fs = require 'fs'

AWS.config.loadFromPath './credentials.json'

AWS.config.update { region: 'us-east-1' }

ec2 = new AWS.EC2().client

script = fs.readFileSync('./initinstance').toString('base64')

interval = (ms, func) -> setInterval func, ms


showInstanceDetails = (id) ->
  params =
    InstanceIds: [ id ]

  ec2.describeInstances params, (err, data) ->
    console.log '.'
    console.log "Instance data:"
    console.log JSON.stringify(data, null, 4)
    console.log '------'
    console.log "Instance public IP: #{data.Reservations[0].Instances?[0].PublicIpAddress}"
    process.exit 0

params =
  ImageId: 'ami-7539b41c'
  MinCount: 1
  MaxCount: 1
  UserData: script
  InstanceType: 't1.micro'
  SecurityGroups: [ 'quicklaunch-0' ]
  KeyName: 'bob1'

ec2.runInstances params, (err, data) ->
  if err?
    console.log 'There was an error launching the instance:'
    console.log err
  else
    console.log "Instance launched:"
    console.log JSON.stringify(data, null, 4)
    console.log "Waiting for boot.."
    interval 2000, ->
      which =
        InstanceIds: [ data?.Instances?[0].InstanceId ]
      ec2.describeInstanceStatus which, (err, data) ->
        if err?
          console.log 'Error getting instance status.'
          console.log err
        else
          process.stdout.write '.'
          status = data.InstanceStatuses?[0].InstanceState?.Name
          if status is 'running'
            showInstanceDetails which.InstanceIds[0]




