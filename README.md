# Linux Containers on Red Hat Enterprise Linux (Podman)

The main difference between Podman and Docker is Podman’s daemonless architecture.
- Podman is best suited for developers running containers without Kubernetes or OpenShift Container Platform.
- Podman is included with a Red Hat Enterprise Linux subscription so you can run OCI-compliant containers that are built using a trusted, supportable, and reliable universal base image (UBI). 
- By using Ansible Playbooks, Red Hat Ansible® Automation Platform allows you to [automate Podman functions](https://www.redhat.com/sysadmin/automate-podman-ansible) like installation, container deployment, and other tasks that frequently consume time and resources. 

## [YouTube - Rootless Containers with Podman](https://www.youtube.com/watch?v=N4ki5Sffy-E)

__podman__
- CLI experience compatible with the docker cli
- Great for running, building, and sharing containers
- Fundamentally designed with security in mind, leveraging SELinux
- Built-in Rootless support

__buildah__
- Build OCI compatible images as a non-root user
- Multi-stage builds  

__skopeo__
- Performs Operations on container images and image repositories

Rootless Requirements 
- slirp4netns
  The [slirp4netns](https://github.com/rootless-containers/slirp4netns) package provides user-mode networking for unprivileged network namespaces and must be installed on the machine in order for Podman to run in a rootless environment. The package is available on most Linux distributions via their package distribution software such as `yum`, `dnf`, `apt`, `zypper`, etc. If the package is not available, you can build and install slirp4netns from GitHub.

- Increase number of user namespaces
  ```
  # echo "user.max_user_namespaces=28633" > /etc/sysctl.d/userns/conf
  # sysctl -p /etc/sysctl.d/userns.conf
  ```
- Additional subordinate SUBIUD/SUBGIUD entries
  - Only required if using system users
  - `/etc/subuid` and `/etc/subgid` configuration
    - Rootless Podman requires the user running it to have a range of UIDs listed in the files `/etc/subuid` and `/etc/subgid`.
    - For each user that will be allowed to create containers, update /etc/subuid and /etc/subgid for the user with fields that look like the following. Note that the values for each user must be unique. If there is overlap, there is a potential for a user to use another user's namespace and they could corrupt it.  
      ```
      cat /etc/subuid
      johndoe:100000:65536
      test:165536:65536
      ```
    - The format of this file is `USERNAME:UID:RANGE`
      - username as listed in `/etc/passwd` or in the output of [`getpwent`](https://man7.org/linux/man-pages/man3/getpwent.3.html).
      - The initial UID allocated for the user.
      - The size of the range of UIDs allocated for the user.
    - the `usermod` program can be used to assign UIDs and GIDs to a user.
        ```
        usermod --add-subuids 100000-165535 --add-subgids 100000-165535 johndoe
        grep johndoe /etc/subuid /etc/subgid
        /etc/subuid:johndoe:100000:65536
        /etc/subgid:johndoe:100000:65536
        ```

Enable container as systemd service

```bash
# cat << EOF | sudo tee /etc/systemd/system/hass.service
[Unit]
Description=Application in Container
After=network.target

[Service]
User=cntuser
Group=cntuser
Type=simple
TimeoutStartSec=5m
ExecStartPre=-/usr/bin/podman rm -f "myapp"
ExecStart=podman run --name=myapp -v /var/lib/myapp/ssl:/ssl:ro -v /var/lib/myapp/config:/config -v /etc/localtime:/etc/localtime:ro --net=host docker.io/homeassistant/home-assistant:latest
ExecReload=-/usr/bin/podman stop "myapp"
ExecReload=-/usr/bin/podman rm "myapp"
ExecStop=-/usr/bin/podman stop "myapp"
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
```

Upgrading Podman

After major Podman upgrade
```
podman system migrate
```

And if you're still experiencing issues try 
```
podman system reset
```

# Resources 
[Getting Started with Podman](https://podman.io/getting-started/)

[How does rootless Podman work?](https://opensource.com/article/19/2/how-does-rootless-podman-work)

[Rootless contianers with Podman: The basics](https://developers.redhat.com/blog/2020/09/25/rootless-containers-with-podman-the-basics)

[YouTube - Rootless Containers with Podman](https://www.youtube.com/watch?v=N4ki5Sffy-E)

[Blog - Rootless Containers with Podman](https://www.redhat.com/sysadmin/rootless-containers-podman)

[Basic Setup and Use of Podman in a Rootless environment](https://github.com/containers/podman/blob/main/docs/tutorials/rootless_tutorial.md)

[Experimenting with Podman](https://levelup.gitconnected.com/experimenting-with-podman-e6cb24428bfd)