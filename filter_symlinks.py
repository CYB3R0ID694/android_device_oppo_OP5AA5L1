import os
import stat

list_file = "proprietary-files.txt"
work_dir = "/Users/sanket/.gemini/antigravity/FindX8/ota_work/extracted"

with open(list_file, 'r') as f:
    lines = f.readlines()

out_lines = []
symlinks_removed = 0
for line in lines:
    clean_line = line.strip()
    if clean_line.startswith('-'):
        rel_path = clean_line[1:]
        full_path = os.path.join(work_dir, rel_path.split(';')[0].split('|')[0])
        
        try:
            st = os.lstat(full_path)
            import stat
            if stat.S_ISLNK(st.st_mode):
                symlinks_removed += 1
                continue
            if st.st_size == 0:
                symlinks_removed += 1
                continue
        except FileNotFoundError:
            symlinks_removed += 1
            continue
            
    out_lines.append(line)

print(f"Removed {symlinks_removed} symlinks or missing files.")

with open(list_file, 'w') as f:
    f.writelines(out_lines)
