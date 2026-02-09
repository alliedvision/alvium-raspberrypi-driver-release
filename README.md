# Allied Vision CSI2 driver for Raspberry Pi

## Beta Disclaimer

Please be aware that all code revisions not explicitly listed in the Github Release section are
considered a **Beta Version**.

For Beta Versions, the following applies in addition to the BSD 3-Clause License:

THE SOFTWARE IS PRELIMINARY AND STILL IN TESTING AND VERIFICATION PHASE AND IS PROVIDED ON AN “AS
IS” AND “AS AVAILABLE” BASIS AND IS BELIEVED TO CONTAIN DEFECTS. THE PRIMARY PURPOSE OF THIS EARLY
ACCESS IS TO OBTAIN FEEDBACK ON PERFORMANCE AND THE IDENTIFICATION OF DEFECTS IN THE SOFTWARE,
HARDWARE AND DOCUMENTATION.

## Compatibilty 
### SoMs + Carrier Boards 
- Raspberry PI 5 B
- Raspberry CM5 + CM5IO carrier
### Cameras + Adapter Board
- Alvium C series camera with FW14
- Adapter Board Alvium CSI-2, part number 22560
- FPC Cable Alvium CSI-2, e.g. 120mm part number 12316

## Installing 
The installation instructions are tested with the Raspberry Pi OS, but should work for every Debian based Linux distribution.
1. Install prerequisites
    ```sh
    sudo apt install build-essential linux-headers-$(uname -r) git
    ```
2. Clone this repository
    ```sh
    git clone https://github.com/alliedvision/alvium-raspberrypi-driver
    ```
3. Build driver
    ```sh 
    cd alvium-raspberrypi-driver
    make
    ```
4. Install driver
    ```sh
    sudo make install
    ```
5. Activate device tree overlay
    ```sh
    echo dtoverlay=alvium-pi5 | sudo tee -a /boot/firmware/config.txt
    ```
6. Reboot
    ```sh
    sudo reboot
    ```

## Quick start
On the Raspberry Pi it is required to manually configure the media pipeline before streaming. 
This example configuration configures the media pipeline for RGB streaming.
The first step is to find out on which media device the Alvium is connected. This can be done using:
```sh
media-ctl -d<X> -p | grep avt
```
The Raspberry Pi 5 driver expose 5 media device by default. Repeat the command for X in {0..4} until the media device containing the Alvium camera is found. The index may change after a reboot. The output will look like this:
```sh
rpi@pi5:~ $ media-ctl -d2 -p |grep avt
                <- "avt_csi2 10-003c":0 [ENABLED,IMMUTABLE]
- entity 16: avt_csi2 10-003c (1 pad, 1 link, 0 routes)
```
Now the link between the CSI receiver subdevice and the first video device needs to be activated:
```sh
media-ctl -d<X> -l '0:4 -> 18:0 [1]'
```
The next step is configuring the CSI2 receiver subdevice. Before this can be done the resolution of the Alvium must be queried using:
```sh
media-ctl -d<X> --get-v4l2 16:0
```
Now use the format and resolution information to configure the CSI2 receiver subdevice and we also update the format of the Alvium subdevice.
Replace <X> with the media device the Alvium is connected to and <width> and <height> with the queried resolution.
```sh
# Set Alvium format
media-ctl -d<X> --set-v4l2 '16:0 [fmt:BGR888_1X24/<width>x<height> field:none colorspace:srgb ycbcr:601 quantization:full-range]'
# Set CSI receiver format
media-ctl -d<X> --set-v4l2 '1:0 [fmt:BGR888_1X24/<width>x<height> field:none colorspace:srgb ycbcr:601 quantization:full-range]'
```
The last step is to configure the video device format:
```sh
v4l2-ctl -v pixelformat=BGR3,width=<width>,height=<height>
```
Now the system is ready to stream e.g. using the [V4L2Viewer](https://github.com/alliedvision/v4l2viewer).
