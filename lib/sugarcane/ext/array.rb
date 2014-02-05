# Adapted from https://github.com/flyerhzm/code_analyzer
# License: MIT
class Array
  def line_number
    case self[0]
    when :def, :defs, :command, :command_call, :call, :fcall, :method_add_arg,
         :method_add_block, :var_ref, :vcall, :const_ref, :const_path_ref,
         :class, :module, :if, :unless, :elsif, :ifop, :if_mod, :unless_mod,
         :binary, :alias, :symbol_literal, :symbol, :aref, :hash, :assoc_new,
         :string_literal, :massign
      self[1].line_number
    when :assoclist_from_args, :bare_assoc_hash
      self[1][0].line_number
    when :string_add, :opassign
      self[2].line_number
    when :array
      array_values.first.line_number
    when :mlhs_add
      self.last.line_number
    else
      self.last.first if self.last.is_a? Array
    end
  end
end
