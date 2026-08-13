import zipfile
from datetime import datetime
from pathlib import Path
from xml.sax.saxutils import escape

BASE_DIR = Path(__file__).resolve().parents[1]
OUT_PATH = BASE_DIR / "test" / "TestCases_Splash_Login.xlsx"

HEADERS = [
  "Ma_TC",
  "Phan_He",
  "Tieu_De_Kiem_Thu",
  "Dieu_Kien_Tien_Quyet",
  "Cac_Buoc_Thuc_Hien",
  "Ket_Qua_Mong_Doi",
  "Do_Uu_Tien",
  "Loai_Kiem_Thu",
  "Tham_Chieu_Ma_Nguon",
]

SPLASH_CASES = [
  ["SP-001", "Splash", "Hiển thị logo splash", "Ứng dụng vừa được mở", "1. Mở ứng dụng", "Màn hình splash hiển thị logo ứng dụng", "Cao", "UI", "lib/splash.dart"],
  ["SP-002", "Splash", "Chờ khoảng 3 giây trước khi điều hướng", "Ứng dụng vừa khởi chạy", "1. Mở ứng dụng\n2. Quan sát thời gian", "Ứng dụng giữ màn splash khoảng 3 giây trước khi xử lý điều hướng", "Cao", "Chức năng", "lib/splash.dart:24"],
  ["SP-003", "Splash", "Không có session hợp lệ và không có current user", "hasValidSession=false và currentUser=null", "1. Mở ứng dụng", "Điều hướng đến /login", "Nghiêm trọng", "Chức năng", "lib/splash.dart:33"],
  ["SP-004", "Splash", "Không có session hợp lệ nhưng có current user", "hasValidSession=false và currentUser!=null", "1. Mở ứng dụng", "Gọi FirebaseAuth.signOut rồi điều hướng đến /login", "Nghiêm trọng", "Chức năng", "lib/splash.dart:34"],
  ["SP-005", "Splash", "Có session hợp lệ và có current user", "hasValidSession=true và currentUser!=null", "1. Mở ứng dụng", "Phát CheckAuthStatusEvent vào AuthBloc", "Nghiêm trọng", "Tích hợp", "lib/splash.dart:47"],
  ["SP-006", "Splash", "Widget bị hủy trước khi redirect hoàn tất", "Rời splash trước khi hết thời gian chờ", "1. Mở ứng dụng\n2. Điều hướng sang màn khác nhanh", "Không bị crash và không điều hướng khi widget không còn mounted", "Cao", "Độ ổn định", "lib/splash.dart:27"],
  ["SP-007", "Splash", "Lỗi sign out ở nhánh session không hợp lệ", "hasValidSession=false, currentUser!=null, signOut ném lỗi", "1. Mở ứng dụng", "Lỗi sign out được bỏ qua an toàn và ứng dụng vẫn điều hướng /login", "Cao", "Khả năng chịu lỗi", "lib/splash.dart:36"],
  ["SP-008", "Splash", "Gọi debug print", "Ứng dụng mở tại splash", "1. Mở ứng dụng\n2. Kiểm tra log", "AuthStorageService.debugPrint được gọi sau khi đọc session", "Trung bình", "Chẩn đoán", "lib/splash.dart:31"],
]

LOGIN_CASES = [
  ["LG-001", "Đăng nhập", "Hiển thị đầy đủ thành phần giao diện đăng nhập", "Đang ở màn hình đăng nhập", "1. Mở màn hình đăng nhập", "Có các thành phần email, mật khẩu, ghi nhớ, quên mật khẩu, đăng nhập, đăng nhập Google", "Cao", "UI", "lib/presentation/pages/screens/auth/login_screen.dart"],
  ["LG-002", "Đăng nhập", "Vô hiệu nút đăng nhập khi form không hợp lệ", "Màn hình đăng nhập đã mở", "1. Giữ email/mật khẩu không hợp lệ", "Nút đăng nhập bị vô hiệu", "Cao", "Chức năng", "login_screen.dart:_isFormValid"],
  ["LG-003", "Đăng nhập", "Kiểm tra email rỗng", "Màn hình đăng nhập đã mở", "1. Để trống email\n2. Gửi form", "Hiển thị lỗi please_enter_email", "Cao", "Xác thực dữ liệu", "login_screen.dart:email validator"],
  ["LG-004", "Đăng nhập", "Kiểm tra email sai định dạng", "Màn hình đăng nhập đã mở", "1. Nhập abc\n2. Gửi form", "Hiển thị lỗi invalid_email_format", "Cao", "Xác thực dữ liệu", "login_screen.dart:email validator"],
  ["LG-005", "Đăng nhập", "Kiểm tra mật khẩu rỗng", "Màn hình đăng nhập đã mở", "1. Để trống mật khẩu\n2. Gửi form", "Hiển thị lỗi please_enter_password", "Cao", "Xác thực dữ liệu", "login_screen.dart:password validator"],
  ["LG-006", "Đăng nhập", "Kiểm tra mật khẩu ngắn hơn 6 ký tự", "Màn hình đăng nhập đã mở", "1. Nhập 12345\n2. Gửi form", "Hiển thị lỗi password_min_6", "Cao", "Xác thực dữ liệu", "login_screen.dart:password validator"],
  ["LG-007", "Đăng nhập", "Chuyển đổi hiển thị mật khẩu", "Ô mật khẩu đã có giá trị", "1. Nhấn biểu tượng con mắt", "Trạng thái ẩn/hiện mật khẩu thay đổi đúng", "Trung bình", "UI", "login_screen.dart:suffixIcon"],
  ["LG-008", "Đăng nhập", "Bật chức năng ghi nhớ đăng nhập", "Đang ở màn đăng nhập", "1. Chọn ghi nhớ đăng nhập", "Gọi saveRememberMe với email/mật khẩu hiện tại", "Cao", "Tích hợp", "login_screen.dart:checkbox onChanged"],
  ["LG-009", "Đăng nhập", "Tắt chức năng ghi nhớ đăng nhập", "Ghi nhớ đăng nhập đang bật", "1. Bỏ chọn ghi nhớ đăng nhập", "Gọi clearRememberMe", "Cao", "Tích hợp", "login_screen.dart:checkbox onChanged"],
  ["LG-010", "Đăng nhập", "Điều hướng tới màn quên mật khẩu", "Đang ở màn đăng nhập", "1. Nhấn quên mật khẩu", "Điều hướng tới ForgotPasswordScreen", "Trung bình", "Điều hướng", "login_screen.dart:forgot password button"],
  ["LG-011", "Đăng nhập", "Điều hướng tới màn đăng ký", "Đang ở màn đăng nhập", "1. Nhấn đăng ký", "Điều hướng tới RegisterScreen", "Trung bình", "Điều hướng", "login_screen.dart:register link"],
  ["LG-012", "Đăng nhập", "Hiển thị trạng thái đang tải", "AuthBloc phát AuthLoading", "1. Kích hoạt đăng nhập", "Hiển thị CircularProgressIndicator", "Cao", "Trạng thái UI", "login_screen.dart:BlocConsumer builder"],
  ["LG-013", "Đăng nhập", "Hiển thị thông báo lỗi đăng nhập", "AuthBloc phát AuthError", "1. Kích hoạt đăng nhập thất bại", "Hiển thị khung lỗi với nội dung lỗi", "Cao", "Trạng thái UI", "login_screen.dart:BlocConsumer listener"],
  ["LG-014", "Đăng nhập", "Tự ẩn lỗi sau 8 giây", "Thông báo lỗi đang hiển thị", "1. Chờ 8 giây", "Thông báo lỗi tự xóa nếu không đổi nội dung", "Trung bình", "UX", "login_screen.dart:Future.delayed 8s"],
  ["LG-015", "Đăng nhập", "Đóng lỗi thủ công", "Thông báo lỗi đang hiển thị", "1. Nhấn biểu tượng đóng", "Thông báo lỗi biến mất ngay", "Trung bình", "UI", "login_screen.dart:close icon"],
  ["LG-016", "Đăng nhập", "Luồng thành công đăng nhập email/mật khẩu", "Form hợp lệ và backend trả thành công", "1. Nhập thông tin hợp lệ\n2. Nhấn đăng nhập", "Phát SignInEvent, lưu session, điều hướng về route gốc", "Nghiêm trọng", "E2E", "login_screen.dart + auth_bloc.dart"],
  ["LG-017", "Đăng nhập", "Thao tác đăng nhập Google", "Dịch vụ Google khả dụng", "1. Nhấn đăng nhập bằng Google", "Phát SignInWithGoogleEvent", "Cao", "Tích hợp", "login_screen.dart:Google button"],
  ["LG-018", "Đăng nhập", "Hiển thị nút sinh trắc học", "Thiết bị có hoặc không hỗ trợ sinh trắc", "1. Mở màn hình đăng nhập", "Nút vân tay chỉ xuất hiện khi thiết bị hỗ trợ", "Cao", "UI/Thiết bị", "login_screen.dart:_loadSavedCredentials"],
  ["LG-019", "Đăng nhập", "Đăng nhập sinh trắc khi thiếu thông tin đã lưu", "savedEmail hoặc savedPassword null/rỗng", "1. Nhấn nút vân tay", "Hiển thị lỗi yêu cầu đăng nhập bằng email/mật khẩu", "Cao", "Chức năng", "login_screen.dart:_handleBiometricLogin"],
  ["LG-020", "Đăng nhập", "Đăng nhập sinh trắc khi email không khớp", "Email nhập tay khác email đã lưu", "1. Nhập email khác\n2. Nhấn nút vân tay", "Hiển thị lỗi email không khớp", "Cao", "Xác thực dữ liệu", "login_screen.dart:_handleBiometricLogin"],
  ["LG-021", "Đăng nhập", "Xác thực sinh trắc thất bại", "Đã có thông tin đăng nhập lưu", "1. Nhấn nút vân tay\n2. Xác thực thất bại", "Hiển thị thông báo xác thực sinh trắc thất bại", "Cao", "Chức năng", "login_screen.dart:_handleBiometricLogin"],
  ["LG-022", "Đăng nhập", "Sinh trắc thành công với session hợp lệ", "authenticated=true, currentUser!=null, hasSavedSession=true", "1. Nhấn nút vân tay", "Phát CheckAuthStatusEvent", "Nghiêm trọng", "Tích hợp", "login_screen.dart:_handleBiometricLogin"],
  ["LG-023", "Đăng nhập", "Sinh trắc thành công nhưng cần đăng nhập lại", "authenticated=true nhưng không có currentUser hoặc không có session hợp lệ", "1. Nhấn nút vân tay", "Tự điền email đã lưu và phát SignInEvent(savedEmail, savedPassword)", "Nghiêm trọng", "Tích hợp", "login_screen.dart:_handleBiometricLogin"],
  ["LG-024", "Đăng nhập", "Ngăn yêu cầu sinh trắc lặp lại", "_isBiometricAuthenticating=true", "1. Nhấn nút vân tay liên tục", "Các lần nhấn thêm bị bỏ qua trong lúc đang xác thực", "Trung bình", "Độ ổn định", "login_screen.dart:_handleBiometricLogin"],
  ["LG-025", "Đăng nhập", "Lưu session khi trạng thái Authenticated", "AuthBloc phát Authenticated", "1. Hoàn tất đăng nhập thành công", "saveLoginSession được gọi với uid, email, role, rememberMe, password", "Nghiêm trọng", "Tích hợp", "login_screen.dart:Auth listener"],
  ["LG-026", "Đăng nhập", "Đổi ngôn ngữ bằng bộ chọn ngôn ngữ", "Đang ở màn đăng nhập", "1. Mở menu ngôn ngữ\n2. Chọn EN hoặc VI", "LocaleCubit.changeLocale được gọi và locale được cập nhật", "Trung bình", "Đa ngôn ngữ", "login_screen.dart:_buildLanguageSelector"],
  ["LG-027", "Đăng nhập-Backend", "Chặn đăng nhập khi isActive=false", "Tài liệu người dùng Firestore có isActive=false", "1. Gọi signIn datasource", "Đăng xuất và ném lỗi tài khoản bị khóa", "Nghiêm trọng", "Unit", "lib/data/datasources/auth_remote_datasource.dart"],
  ["LG-028", "Đăng nhập-Backend", "Chặn đăng nhập khi trạng thái bị khóa", "accountStatus thuộc disabled/locked/inactive", "1. Gọi signIn datasource", "Đăng xuất và ném lỗi tài khoản bị khóa", "Nghiêm trọng", "Unit", "lib/data/datasources/auth_remote_datasource.dart"],
  ["LG-029", "Đăng nhập-Backend", "Ánh xạ lỗi FirebaseAuth sang thông báo", "FirebaseAuthException được ném", "1. Kích hoạt các lỗi user-not-found, wrong-password, invalid-email...", "Trả về thông báo thân thiện đúng theo mã lỗi", "Cao", "Unit", "auth_remote_datasource.dart:switch e.code"],
  ["LG-030", "Đăng nhập-Backend", "Trả UserModel mặc định khi thiếu hồ sơ Firestore", "Đăng nhập Firebase thành công nhưng thiếu users uid doc", "1. Gọi signIn datasource", "Trả UserModel mặc định với role=patient", "Cao", "Unit", "auth_remote_datasource.dart:signIn fallback"],
  ["LG-031", "Đăng nhập-Backend", "Tạo hồ sơ người dùng cho lần đầu đăng nhập Google", "Google auth thành công và thiếu users uid doc", "1. Gọi signInWithGoogle", "Tạo tài liệu người dùng Firestore với role mặc định", "Cao", "Unit", "auth_remote_datasource.dart:signInWithGoogle"],
  ["LG-032", "Đăng nhập-Backend", "Chặn tài khoản bị khóa khi đăng nhập Google", "Hồ sơ người dùng có trạng thái disabled/locked/inactive", "1. Gọi signInWithGoogle", "Đăng xuất Firebase và Google rồi ném lỗi tài khoản bị khóa", "Nghiêm trọng", "Unit", "auth_remote_datasource.dart:signInWithGoogle"],
]


def col_name(index: int) -> str:
    result = ""
    while index:
        index, rem = divmod(index - 1, 26)
        result = chr(65 + rem) + result
    return result


def build_sheet_xml(rows):
    all_rows = [HEADERS] + rows
    max_col = len(HEADERS)
    max_row = len(all_rows)
    dim = f"A1:{col_name(max_col)}{max_row}"

    width_map = {1: 12, 2: 14, 3: 40, 4: 45, 5: 55, 6: 55, 7: 10, 8: 14, 9: 45}
    cols = "".join(
        f'<col min="{c}" max="{c}" width="{width_map.get(c, 20)}" customWidth="1"/>'
        for c in range(1, max_col + 1)
    )

    row_xml = []
    for r_idx, row in enumerate(all_rows, start=1):
        style = "1" if r_idx == 1 else "0"
        cells = []
        for c_idx, value in enumerate(row, start=1):
            ref = f"{col_name(c_idx)}{r_idx}"
            text = escape(str(value))
            cells.append(
                f'<c r="{ref}" t="inlineStr" s="{style}"><is><t xml:space="preserve">{text}</t></is></c>'
            )
        row_xml.append(f'<row r="{r_idx}" spans="1:{max_col}">{"".join(cells)}</row>')

    return (
        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>"
        "<worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" "
        "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\">"
        f"<dimension ref=\"{dim}\"/>"
        "<sheetViews><sheetView workbookViewId=\"0\"/></sheetViews>"
        "<sheetFormatPr defaultRowHeight=\"18\"/>"
        f"<cols>{cols}</cols>"
        f"<sheetData>{''.join(row_xml)}</sheetData>"
        "</worksheet>"
    )


CONTENT_TYPES = """<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">
  <Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>
  <Default Extension=\"xml\" ContentType=\"application/xml\"/>
  <Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/>
  <Override PartName=\"/xl/worksheets/sheet1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>
  <Override PartName=\"/xl/worksheets/sheet2.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>
  <Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/>
  <Override PartName=\"/docProps/core.xml\" ContentType=\"application/vnd.openxmlformats-package.core-properties+xml\"/>
  <Override PartName=\"/docProps/app.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.extended-properties+xml\"/>
</Types>
"""

ROOT_RELS = """<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">
  <Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/>
  <Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties\" Target=\"docProps/core.xml\"/>
  <Relationship Id=\"rId3\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties\" Target=\"docProps/app.xml\"/>
</Relationships>
"""

WORKBOOK = """<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<workbook xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\">
  <sheets>
    <sheet name=\"TC_Splash\" sheetId=\"1\" r:id=\"rId1\"/>
    <sheet name=\"TC_DangNhap\" sheetId=\"2\" r:id=\"rId2\"/>
  </sheets>
</workbook>
"""

WORKBOOK_RELS = """<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">
  <Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet1.xml\"/>
  <Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet2.xml\"/>
  <Relationship Id=\"rId3\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/>
</Relationships>
"""

STYLES = """<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<styleSheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">
  <fonts count=\"2\">
    <font><sz val=\"11\"/><name val=\"Calibri\"/></font>
    <font><b/><sz val=\"11\"/><name val=\"Calibri\"/></font>
  </fonts>
  <fills count=\"2\">
    <fill><patternFill patternType=\"none\"/></fill>
    <fill><patternFill patternType=\"gray125\"/></fill>
  </fills>
  <borders count=\"1\">
    <border><left/><right/><top/><bottom/><diagonal/></border>
  </borders>
  <cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs>
  <cellXfs count=\"2\">
    <xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\" applyAlignment=\"1\"><alignment wrapText=\"1\" vertical=\"top\"/></xf>
    <xf numFmtId=\"0\" fontId=\"1\" fillId=\"0\" borderId=\"0\" xfId=\"0\" applyAlignment=\"1\"><alignment wrapText=\"1\" vertical=\"center\" horizontal=\"center\"/></xf>
  </cellXfs>
  <cellStyles count=\"1\"><cellStyle name=\"Normal\" xfId=\"0\" builtinId=\"0\"/></cellStyles>
</styleSheet>
"""


def build_core_props():
    now = datetime.utcnow().replace(microsecond=0).isoformat() + "Z"
    return f"""<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<cp:coreProperties xmlns:cp=\"http://schemas.openxmlformats.org/package/2006/metadata/core-properties\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:dcterms=\"http://purl.org/dc/terms/\" xmlns:dcmitype=\"http://purl.org/dc/dcmitype/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">
  <dc:title>Doctor Care - Test case Splash va Dang nhap</dc:title>
  <dc:creator>GitHub Copilot</dc:creator>
  <cp:lastModifiedBy>GitHub Copilot</cp:lastModifiedBy>
  <dcterms:created xsi:type=\"dcterms:W3CDTF\">{now}</dcterms:created>
  <dcterms:modified xsi:type=\"dcterms:W3CDTF\">{now}</dcterms:modified>
</cp:coreProperties>
"""


APP_PROPS = """<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>
<Properties xmlns=\"http://schemas.openxmlformats.org/officeDocument/2006/extended-properties\" xmlns:vt=\"http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes\">
  <Application>Microsoft Excel</Application>
  <HeadingPairs>
    <vt:vector size=\"2\" baseType=\"variant\">
      <vt:variant><vt:lpstr>Worksheets</vt:lpstr></vt:variant>
      <vt:variant><vt:i4>2</vt:i4></vt:variant>
    </vt:vector>
  </HeadingPairs>
  <TitlesOfParts>
    <vt:vector size=\"2\" baseType=\"lpstr\">
      <vt:lpstr>TC_Splash</vt:lpstr>
      <vt:lpstr>TC_DangNhap</vt:lpstr>
    </vt:vector>
  </TitlesOfParts>
</Properties>
"""


def main():
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(OUT_PATH, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("[Content_Types].xml", CONTENT_TYPES)
        zf.writestr("_rels/.rels", ROOT_RELS)
        zf.writestr("xl/workbook.xml", WORKBOOK)
        zf.writestr("xl/_rels/workbook.xml.rels", WORKBOOK_RELS)
        zf.writestr("xl/styles.xml", STYLES)
        zf.writestr("xl/worksheets/sheet1.xml", build_sheet_xml(SPLASH_CASES))
        zf.writestr("xl/worksheets/sheet2.xml", build_sheet_xml(LOGIN_CASES))
        zf.writestr("docProps/core.xml", build_core_props())
        zf.writestr("docProps/app.xml", APP_PROPS)

    print(f"Created: {OUT_PATH}")
    print(f"Splash test cases: {len(SPLASH_CASES)}")
    print(f"Login test cases: {len(LOGIN_CASES)}")


if __name__ == "__main__":
    main()
