class String
   def to_minusculas_sem_acentos_e_cia
    self.downcase
        .gsub(/[ÁÃÂÀáãâà]/,'a')
        .gsub(/[ÉÊÈéêè]/,'e')
        .gsub(/[ÍÌÎíìî]/,'i')
        .gsub(/[ÔÓÕÒòôõóÖö]/,'o')
        .gsub(/[ÚÙÛúûùúùû]/,'u')
        .gsub(/[Çç]/,'c')
        .gsub(/[º]/,'o')
        .gsub(/[ª]/,'a')
  end
end
