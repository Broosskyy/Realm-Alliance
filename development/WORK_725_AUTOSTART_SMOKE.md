# WORK 725 – Automatic startup update on installed 724

Build-only OTA acceptance candidate: 725 uses the same Android ID and verified signing certificate, retains gameplay and save format, and tests the 724 startup downloader. The GitHub release is signed automatically. The test manifest stays at version 724 until the user confirms successful manual installation of 724 over the broken 720. Then publishing 725 in the manifest triggers automatic download and Android's required confirmation dialog at next launch. Do not claim end-to-end success without device evidence.
