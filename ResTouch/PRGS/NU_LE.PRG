PROCEDURE NU_LE
if int(nu) = 0
   store 'CERO QUETZALES' to le
   do case
      case ((nu-int(nu))*100) = 0
           store le+' CON 00/100.'                             to le
      case ((nu-int(nu))*100) < 10
           store le+' CON 0'+str(((nu-int(nu))*100),1)+'/100.' to le
      otherwise
           store le+' CON '+str(((nu-int(nu))*100),2)+'/100.'  to le
   endcase
   return
endif
store int(nu) to nn
store ''      to le
millon = int(nn/1000000)
if millon <> 0
   do case
      case millon = 1
           store 'UN MILLON'              to le
      case millon > 1
           store ve(1,millon)+' MILLONES' to le
   endcase
endif
nn = nn - (millon*1000000)
centenas = int(nn/1000)
if centenas <> 0
   do case
      case centenas = 1 .and. millon = 0
           store le+' MIL'                to le
           nn = nn - (centenas*1000)
      case centenas = 1 .and. millon > 0
           store le+' UN MIL'             to le
           nn = nn - (centenas*1000)
      case centenas = 100
           store le+' CIEN MIL'           to le
           nn = nn - (centenas*1000)
      case centenas < 30
           store le+' '+ve(1,centenas)+' MIL' to le
           nn = nn - (centenas*1000)
      otherwise
           centenas = int(nn/100000)
           if centenas <> 0
              store le+' '+ve(2,centenas)     to le
              nn = nn - (centenas*100000)
              decenas = int(nn/1000)
              if decenas <> 0
                 do case
                    case decenas < 30
                         store le+' '+ve(1,decenas) to le
                         nn = nn - (decenas*1000)
                    otherwise
                         decenas = int(nn/10000)
                         store le+' '+ve(3,decenas) to le
                         nn = nn - (decenas*10000)
                         unidad = int(nn/1000)
                         if unidad <> 0
                            store le+' Y '+ve(1,unidad) to le
                         endif
                         nn = nn - (unidad*1000)
                 endcase
              endif
           else
              decenas = int(nn/1000)
              if decenas <> 0
                 do case
                    case decenas < 30
                         store le+' '+ve(1,decenas) to le
                         nn = nn - (decenas*1000)
                    otherwise
                         decenas = int(nn/10000)
                         store le+' '+ve(3,decenas) to le
                         nn = nn - (decenas*10000)
                         unidad = int(nn/1000)
                         if unidad <> 0
                            store le+' Y '+ve(1,unidad) to le
                         endif
                         nn = nn - (unidad*1000)
                 endcase
              endif
           endif
           store le+' MIL'             to le
   endcase
endif
centenas = nn
if centenas <> 0
   do case
      case centenas = 100
           store le+' CIEN'               to le
           nn = nn - centenas
      case centenas < 30
           store le+' '+ve(1,centenas)    to le
           nn = nn - centenas
      otherwise
           centenas = int(nn/100)
           if centenas <> 0
              store le+' '+ve(2,centenas)     to le
              nn = nn - (centenas*100)
              decenas = nn
              if decenas <> 0
                 do case
                    case decenas < 30
                         store le+' '+ve(1,decenas) to le
                         nn = nn - decenas
                    otherwise
                         decenas = int(nn/10)
                         store le+' '+ve(3,decenas) to le
                         nn = nn - (decenas*10)
                         unidad = nn
                         if unidad <> 0
                            store le+' Y '+ve(1,unidad) to le
                         endif
                         nn = nn - unidad
                 endcase
              endif
           else
              decenas = nn
              if decenas <> 0
                 do case
                    case decenas < 30
                         store le+' '+ve(1,decenas) to le
                         nn = nn - decenas
                    otherwise
                         decenas = int(nn/10)
                         store le+' '+ve(3,decenas) to le
                         nn = nn - (decenas*10)
                         unidad = nn
                         if unidad <> 0
                            store le+' Y '+ve(1,unidad) to le
                         endif
                         nn = nn - unidad
                 endcase
              endif
           endif
   endcase
endif
do case
   case ((nu-int(nu))*100) = 0
        store le+' CON 00/100.'                             to le
 *  case ((nu-int(nu))*100) < 10
 *       store le+' CON 0'+str(((nu-int(nu))*100),1)+'/100.' to le
   otherwise
        store le+' CON '+str(((nu-int(nu))*100),2)+'/100.'  to le
endcase
return
