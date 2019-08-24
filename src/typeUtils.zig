const builtin = @import("builtin");

pub fn ensureAllFieldsHaveTheSameSize(comptime structInfo: builtin.TypeInfo.Struct) bool {
    if (structInfo.fields.len == 0) {
        return true;
    }

    comptime const firstFieldType = structInfo.fields[0].field_type;
    inline for (structInfo.fields) |field| {
        if (field.field_type != firstFieldType) {
            return false;
        }
    }
    return true;
}
