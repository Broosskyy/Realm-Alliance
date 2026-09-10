@echo off
cd /d %~dp0\..
python tools\realm_asset_pipeline.py
pause
