# PSAgentTemplate
PSAgentTemplate is a project template for PowerShell Agents/Scheduled Jobs. While a scheduled job or agent could perform any task, the one I find myself repeating the most is some variation on a 2 step process of 'get data, use data'. This is a base template for that flow.

# Files
- .gitignore
- README.md - this readme file, but modified with current descriptions.
- job.ps1 - main file. this is the file that is called by the scheduled job.
- spec.msg - this is simply an email file containing a thread about this job and hopefully an attachment with any specificiations or sample files provided. in this template it is an empty file. generally i delete the blank file and drag/drop a file from outlook and rename it to spec.msg and upload it.
- get-data.sql - most of our jobs pull data from a sql server and do something with it. This is the sql script used for the 'get data' step.
- settings.json - settings file

# Legal and Licensing
PSAgentTemplate is licensed under the MIT license.

---

__*template readme.md starts below this section. modify to taste then remove the top section.*__

---

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
- Deploy job
  - Confirm settings in:
    - settings.json
  - Run `iex (irm deployscripturl)`
  
_Note: To update, re-run `iex command`_