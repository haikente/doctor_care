"""
Script gộp food_database.json (cũ) + food_database_from_excel.json (mới)
thành 1 file food_database.json duy nhất, bỏ trùng lặp.

Ưu tiên: giữ bản từ file cũ (có name_en, category đầy đủ hơn).
Chạy: python tool/merge_food_db.py
"""

import json
import re
import unicodedata


def normalize_name(name: str) -> str:
    """Chuẩn hóa tên để so sánh trùng lặp"""
    text = name.lower().strip()
    # Bỏ khoảng trắng thừa, dấu phẩy, ngoặc
    text = re.sub(r'\s+', ' ', text)
    text = text.rstrip(',').strip()
    return text


def remove_diacritics(text: str) -> str:
    """Bỏ dấu tiếng Việt để so sánh"""
    vietnamese_map = {
        'à': 'a', 'á': 'a', 'ả': 'a', 'ã': 'a', 'ạ': 'a',
        'ă': 'a', 'ắ': 'a', 'ằ': 'a', 'ẳ': 'a', 'ẵ': 'a', 'ặ': 'a',
        'â': 'a', 'ấ': 'a', 'ầ': 'a', 'ẩ': 'a', 'ẫ': 'a', 'ậ': 'a',
        'đ': 'd',
        'è': 'e', 'é': 'e', 'ẻ': 'e', 'ẽ': 'e', 'ẹ': 'e',
        'ê': 'e', 'ế': 'e', 'ề': 'e', 'ể': 'e', 'ễ': 'e', 'ệ': 'e',
        'ì': 'i', 'í': 'i', 'ỉ': 'i', 'ĩ': 'i', 'ị': 'i',
        'ò': 'o', 'ó': 'o', 'ỏ': 'o', 'õ': 'o', 'ọ': 'o',
        'ô': 'o', 'ố': 'o', 'ồ': 'o', 'ổ': 'o', 'ỗ': 'o', 'ộ': 'o',
        'ơ': 'o', 'ớ': 'o', 'ờ': 'o', 'ở': 'o', 'ỡ': 'o', 'ợ': 'o',
        'ù': 'u', 'ú': 'u', 'ủ': 'u', 'ũ': 'u', 'ụ': 'u',
        'ư': 'u', 'ứ': 'u', 'ừ': 'u', 'ử': 'u', 'ữ': 'u', 'ự': 'u',
        'ỳ': 'y', 'ý': 'y', 'ỷ': 'y', 'ỹ': 'y', 'ỵ': 'y',
    }
    result = ''
    for char in text.lower():
        result += vietnamese_map.get(char, char)
    return result


def make_compare_key(name: str) -> str:
    """Tạo key để so sánh trùng lặp (bỏ dấu, bỏ khoảng trắng thừa, lowercase)"""
    normalized = normalize_name(name)
    no_diacritics = remove_diacritics(normalized)
    # Chỉ giữ chữ cái và số, thay khoảng trắng bằng _
    cleaned = re.sub(r'[^a-z0-9]', '', no_diacritics)
    return cleaned


def main():
    # Load old (full info)
    with open('assets/database/food_database.json', 'r', encoding='utf-8') as f:
        old_foods = json.load(f)
    print(f"📁 File cũ (food_database.json): {len(old_foods)} món")

    # Load new (from Excel)
    with open('assets/database/food_database_from_excel.json', 'r', encoding='utf-8') as f:
        new_foods = json.load(f)
    print(f"📁 File mới (food_database_from_excel.json): {len(new_foods)} món")

    # Build merged list: ưu tiên bản cũ (có name_en, category)
    merged = {}
    duplicates = []

    # Thêm tất cả từ file cũ trước (ưu tiên)
    for food in old_foods:
        compare_key = make_compare_key(food['name'])
        merged[compare_key] = food

    # Thêm từ file mới, bỏ qua nếu trùng
    new_added = 0
    for food in new_foods:
        compare_key = make_compare_key(food['name'])
        if compare_key in merged:
            duplicates.append(food['name'])
        else:
            # Món mới chưa có trong database cũ → thêm vào
            merged[compare_key] = food
            new_added += 1

    # Convert to list
    result = list(merged.values())

    # Đảm bảo unique keys
    seen_keys = set()
    for item in result:
        if item['key'] in seen_keys:
            counter = 2
            base_key = item['key']
            while f"{base_key}_{counter}" in seen_keys:
                counter += 1
            item['key'] = f"{base_key}_{counter}"
        seen_keys.add(item['key'])

    # Write output
    output_path = 'assets/database/food_database.json'
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, ensure_ascii=False, indent=2)

    print(f"\n✅ Gộp thành công!")
    print(f"   Tổng sau gộp: {len(result)} món")
    print(f"   Từ file cũ: {len(old_foods)} món (giữ nguyên)")
    print(f"   Từ file mới thêm: {new_added} món")
    print(f"   Trùng lặp đã bỏ: {len(duplicates)} món")
    print(f"   Output: {output_path}")

    if duplicates:
        print(f"\n🔄 Các món trùng lặp đã bỏ ({len(duplicates)}):")
        for d in duplicates[:20]:
            print(f"   - {d}")
        if len(duplicates) > 20:
            print(f"   ... và {len(duplicates) - 20} món khác")


if __name__ == '__main__':
    main()
