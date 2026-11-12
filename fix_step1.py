import re
import os
import glob

lib_dir = r"c:\Users\DELL\Desktop\AquaIntel\lib"

# 1. First, replace static const Color foo = AquaColors.bar; with static Color get foo => AquaColors.bar;
# and const Color foo = AquaColors.bar; with Color get foo => AquaColors.bar;
pattern_static_const = re.compile(r'static\s+const\s+Color\s+(\w+)\s*=\s*AquaColors\.(\w+);')
pattern_const = re.compile(r'^\s*const\s+Color\s+(\w+)\s*=\s*AquaColors\.(\w+);', re.MULTILINE)

dart_files = []
for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            dart_files.append(os.path.join(root, f))

for path in dart_files:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = pattern_static_const.sub(r'static Color get \1 => AquaColors.\2;', content)
    new_content = pattern_const.sub(r'Color get \1 => AquaColors.\2;', new_content)


    if new_content != content:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated static const in {os.path.basename(path)}")

print("Step 1 complete.")
