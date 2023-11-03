ARG ROS_DISTRO=humble
FROM ros:$ROS_DISTRO-ros-base AS pkg-builder
SHELL ["/bin/bash", "-c"]

WORKDIR /ros2_ws

RUN git clone https://github.com/wust-dcr/ros2aria --recursive src/ && \
    source /opt/ros/$ROS_DISTRO/setup.bash && \
    rm -rf /etc/ros/rosdep/sources.list.d/20-default.list && \
    rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO && \
    rosdep install -i --from-path src --rosdistro $ROS_DISTRO -y && \
    colcon build

FROM husarnet/ros:$ROS_DISTRO-ros-core
ARG ROS_DISTRO

SHELL ["/bin/bash", "-c"]
WORKDIR /ros2_ws

COPY --from=pkg-builder /ros2_ws /ros2_ws
RUN apt-get update && apt-get install -y python3-rosdep && \
    rm -rf /etc/ros/rosdep/sources.list.d/20-default.list && \
    rosdep init && \
    rosdep update --rosdistro $ROS_DISTRO && \
    rosdep install -i --from-path src --rosdistro $ROS_DISTRO -y

RUN apt-get clean && \
	apt-get remove -y \
		python3-rosdep && \
	rm -rf /var/lib/apt/lists/*