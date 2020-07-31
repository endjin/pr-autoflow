FROM alpine/git as module_builder
WORKDIR /tmp
ARG repoUrl=https://github.com/endjin/dependabot-pr-parser
ARG branch=master
RUN git clone ${repoUrl} \
        && cd dependabot-pr-parser \
        && git checkout ${branch}

FROM mcr.microsoft.com/powershell:7.0.3-alpine-3.8
COPY --from=module_builder /tmp/dependabot-pr-parser/module/ /tmp/module/
COPY ./pwsh-profile.ps1 /root/.config/powershell/Microsoft.PowerShell_profile.ps1
COPY . /tmp/
ENTRYPOINT ["pwsh","-File","/tmp/RunAction.ps1"]
