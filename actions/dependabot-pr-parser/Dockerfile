FROM endjin/endjin.githubactions.powershell:1.0.4-beta.3
COPY . /tmp/
RUN pwsh -f /tmp/prepare-module.ps1
ENTRYPOINT ["pwsh","-File","/tmp/entrypoint.ps1"]
