# android_device_oppo_OP5AA5L1

Device tree for the **Oppo Find X8** (Global) for [LineageOS 23.1](https://lineageos.org/).

## Device specifications

| Feature | Specification |
|---|---|
| **Codename** | `OP5AA5L1` |
| **Model** | CPH2651 |
| **SoC** | MediaTek Dimensity 9400 (mt6991) |
| **CPU** | 1x Cortex-X925 + 3x Cortex-X4 + 4x Cortex-A720 |
| **GPU** | Immortalis-G925 MC12 |
| **RAM** | 12 GB / 16 GB LPDDR5X |
| **Storage** | 256 GB / 512 GB UFS 4.0 |
| **Display** | 6.59" AMOLED, 2760×1256, 120Hz LTPO |
| **Camera** | 50MP (main) + 50MP (ultrawide) + 50MP (telephoto) |
| **Battery** | 5910 mAh, 100W wired, 50W wireless |
| **OS** | Android 16 (ColorOS 16) |
| **Kernel** | Linux 6.6 (GKI 2.0) |

## Kernel source

| Repository | Branch |
|---|---|
| [android_kernel_oppo_mt6991](https://github.com/oppo-source/android_kernel_oppo_mt6991) | `oppo/mt6991_b_16.0.0_find_x8` |
| [android_kernel_modules_and_devicetree_oppo_mt6991](https://github.com/oppo-source/android_kernel_modules_and_devicetree_oppo_mt6991) | `oppo/mt6991_b_16.0.0_find_x8` |

## Build instructions

### 1. Initialize LineageOS 23.1 sources

```bash
repo init -u https://github.com/LineageOS/android.git -b lineage-23.1 --git-lfs
repo sync -c -j$(nproc) --force-sync --no-clone-bundle
```

### 2. Clone device tree

```bash
git clone https://github.com/CYB3R0ID694/android_device_oppo_OP5AA5L1 device/oppo/OP5AA5L1 -b lineage-23.1
```

### 3. Clone vendor blobs

```bash
git clone https://github.com/CYB3R0ID694/android_vendor_oppo_OP5AA5L1 vendor/oppo/OP5AA5L1 -b lineage-23.1
```

### 4. Extract kernel artifacts & vendor blobs

With device connected via ADB (root enabled):
```bash
cd device/oppo/OP5AA5L1
./extract-blobs-adb.sh
```

Or from a stock OTA zip:
```bash
# From the Android source root:
./device/oppo/OP5AA5L1/extract-from-ota.sh /path/to/CPH2651_OTA.zip
```

### 5. Build

```bash
source build/envsetup.sh
lunch lineage_OP5AA5L1-userdebug
mka bacon -j$(nproc)
```

> **⚠️ Linux only** — Android builds require Ubuntu 20.04 or 22.04.

## Status

| Component | Status |
|---|---|
| Boot | 🔧 In Progress |
| Display | 🔧 In Progress |
| Audio | 🔧 In Progress |
| WiFi | 🔧 In Progress |
| Bluetooth | 🔧 In Progress |
| Camera | 🔧 In Progress |
| Fingerprint | 🔧 In Progress |
| NFC | 🔧 In Progress |
| Charging (100W) | 🔧 In Progress |

## Credits

- [LineageOS](https://github.com/LineageOS)
- [OPPO Open Source](https://github.com/oppo-source)
