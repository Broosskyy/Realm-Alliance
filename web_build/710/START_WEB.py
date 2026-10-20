from pathlib import Path
import subprocess,sys
r=Path(__file__).resolve().parent
raise SystemExit(subprocess.call([sys.executable,str(r/"backend/realm_service.py"),"--web-root",str(r),*sys.argv[1:]]))
