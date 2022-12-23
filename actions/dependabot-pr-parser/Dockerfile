FROM endjin/endjin.githubactions.powershell:1.0.4
COPY . /tmp/
ARG AllowPreRelease=false
RUN pwsh -f /tmp/prepare-module.ps1 -AllowPreRelease ${AllowPreRelease}
ENTRYPOINT ["pwsh","-File","/tmp/entrypoint.ps1"]
