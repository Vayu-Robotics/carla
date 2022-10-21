FROM carla:latest

USER root

# Disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y libvulkan1 mesa-vulkan-drivers vulkan-utils xdg-user-dirs xdg-utils
# xorg-dev

# Enable NVENC support for use by Unreal Engine plugins that depend on it (e.g. Pixel Streaming)
ENV NVIDIA_DRIVER_CAPABILITIES all

# Enable Vulkan support
# # RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
# RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
# 	apt-get update && apt-get install -y --no-install-recommends libvulkan1 && \
RUN VULKAN_API_VERSION=`dpkg -s libvulkan1 | grep -oP 'Version: [0-9|\.]+' | grep -oP '[0-9|\.]+'` && \
	mkdir -p /etc/vulkan/icd.d/ && \
	echo \
	"{\
		\"file_format_version\" : \"1.0.0\",\
		\"ICD\": {\
			\"library_path\": \"libGLX_nvidia.so.0\",\
			\"api_version\" : \"${VULKAN_API_VERSION}\"\
		}\
	}" > /etc/vulkan/icd.d/nvidia_icd.json

# Install the `xdg-user-dir` tool so the Unreal Engine can use it to locate the user's Documents directory
# RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
# 	apt-get update && apt-get install -y --no-install-recommends xdg-user-dirs

RUN usermod -a -G audio,video,sudo carla

USER carla
WORKDIR /home/carla/carla
CMD make launch
