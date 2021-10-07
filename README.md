# PSAgentTemplate
PSAgentTemplate is a project template for PowerShell Agents/Scheduled Jobs. While a scheduled job or agent could perform any task, the one I find myself repeating the most is some variation on a 2 step process of 'get data, use data'. This is a base template for that flow.

The output of this template will eventually be a deployed scheduled task on a windows server that calls powershell to invoke job.ps1. For the purpose of this template the word 'agent', 'job', 'scheduled job' and other similar items may all be used to describe the same thing. A future todo may be to standardize that language. =)

Currently some variation of this pattern is used for ~100 jobs and maintained by just myself. If you are looking for something that 'just works', you don't want to write your own job structure, and you don't want to be locked into anything other than the basic shell, you can use this repo as a template like i do or fork it.
# Files
Files are either files that get deployed, or files that do not get deployed.

## Files that do not get deployed
- .gitignore - for use with github
- LICENSE - for use with github
- deploy.ps1 - this is the standardized script for deploying the jobs

## Files that do get deployed
- spec.msg - email file with any rich content i want to include as documentation. may have attachments, etc. mostly to provide context to future support staff
- README.md - readme file can be as light or as detailed as is reasonable. this file should provide a basic overview of the job and be updated if more detail is required for ongoing support. coupled with spec.msg, should give a support person all the detail they need to support the job.
- settings.json - has settings for the job
- get-data.sql - this is not a *requirement* as a job could pull data from locations that don't require sql, but this is the standard pattern i use, so it's included with the 'template'
- job.ps1 - this is the actual job. a scheduled job will invoke this on some schedule from a folder once it is copied

## Additional files not currently listed
- custom powershell modules - if any rich custom logic is required that will not bein job.ps1, including a custom powershell module is relatively common and job.ps1 would import it like: `Import-Module .\custom.psm1 -Force`. the file could be named whatever. sometimes there may be a need to overwrite an existing installed module, and custom versions would be imported this way as well and included.
  - while not included in this project template, most agents make common use of the following public modules:
    - Add-PrefixForLogging
    - Clear-Files
    - Send-FileViaEmail
    - WinSCP
    - ImportExcel
    - SqlServer
- custom required files - sometimes a template file may be populated or perhaps a key file will need to be included with a file in some way. there are many examples but the most common currently are excel templates that are opened and then populated prior to sending to some destination or certificite files required by various jobs.
- additional documentation - in very rare instances, there is a need to have some document readily available to open like a pdf or mapping file. in those cases, the file will be copied separately. typically, these files are simply included in the spec.msg file if needed.

## Detailed File Information
TODO: add more details on the files as many of them have some notes or require some context.

# Version History
Agents followed some type of template even while there was not a central version for quite a long time. Generally jobs were just copied and tailored as needed, but there were some major versions prior to creation of this template. This is simply to provide a timeline and some context around the usage for this template.
## Pre v1 - before 2018 
Before v1, jobs were all custom including many jobs in various languages using various scheduling methods. So prior to v1 our standard was no standard.
## v1 - 2018
v1 was our initial standardization effort. push was migrating all jobs to simply use powershell and windows scheduled jobs. at this time an xml file was used for config and a number of other structural changes existed in the job folder. this was when job.ps1 was established as the default entrypoint.
## v2 - 2019
config moved to json. sql was moved into it's own file (previously was in config). default deploy script established. custom code was moved into an include and dot included as needed. switched to git. all jobs generally had an identical job.ps1 and a custom include.ps1 along with any other supporting files.
## v3 - 2020
documentation consolidated to spec.msg except readme. many standard patterns in v2 were using custom code in the include.ps1 file. switched to using modules for custom code and using standard third party modules instead of dlls where needed.
## v3.2 - 2021
deploy script standardized/centralized completely and deploy config migrated to settings.json. strict added. named sql cmdlet added. this template created.
## Additional/Current versions
see release notes
# Legal and Licensing
PSAgentTemplate is licensed under the MIT license.


__*template readme.md starts below this line. delete this line and all above.*__
# README.md

## Summary

This process gets data from X and uses it to do Y

## Contacts

- Internal
  - IT - Roy Ashbrook
  - Business Contacts - Varies
- External

```
usually this is just copy/pasted from a customers email signature
```

## Deployment

- Clone locally
- Confirm settings.json
- `iex (irm https://raw.githubusercontent.com/royashbrook/PSAgentDeploy/main/deploy.ps1)`
  
_Note: To update, re-run `iex command`_