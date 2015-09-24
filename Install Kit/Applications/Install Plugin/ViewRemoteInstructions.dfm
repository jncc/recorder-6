object dlgViewRemoteInstructions: TdlgViewRemoteInstructions
  Left = 311
  Top = 304
  Width = 655
  Height = 460
  BorderIcons = [biSystemMenu]
  Caption = 'dlgViewRemoteInstructions'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    647
    433)
  PixelsPerInch = 96
  TextHeight = 13
  object reInstructions: TRichEdit
    Left = 4
    Top = 4
    Width = 639
    Height = 387
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object btnPrint: TBitBtn
    Left = 470
    Top = 400
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Print'
    TabOrder = 1
    OnClick = btnPrintClick
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      1800000000000003000000000000000000000000000000000000C6D4DCC6D4DC
      C6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4
      DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DC00000000000000000000000000000000
      0000000000000000000000000000000000C6D4DCC6D4DCC6D4DCC6D4DC000000
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000C0C0
      C0000000C6D4DCC6D4DC00000000000000000000000000000000000000000000
      0000000000000000000000000000000000C0C0C0000000C6D4DC000000C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C000FFFF00FFFF00FFFFC0C0C0C0C0C00000
      00000000000000C6D4DC000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C080
      8080808080808080C0C0C0C0C0C0000000C0C0C0000000C6D4DC000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00C0C0C0C0C0C0000000000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0000000C0C0C0000000C0C0C0000000C6D4DC000000
      000000000000000000000000000000000000000000000000000000C0C0C00000
      00C0C0C0000000000000C6D4DCC6D4DC000000FFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFF000000C0C0C0000000C0C0C0000000C6D4DCC6D4DC
      C6D4DC000000FFFFFF000000000000000000000000000000FFFFFF0000000000
      00000000000000C6D4DCC6D4DCC6D4DCC6D4DC000000FFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF000000C6D4DCC6D4DCC6D4DCC6D4DCC6D4DC
      C6D4DCC6D4DC000000FFFFFF000000000000000000000000000000FFFFFF0000
      00C6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DC000000FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000C6D4DCC6D4DCC6D4DCC6D4DC
      C6D4DCC6D4DCC6D4DC0000000000000000000000000000000000000000000000
      00000000C6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6
      D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DCC6D4DC}
  end
  object btnClose: TBitBtn
    Left = 566
    Top = 400
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 2
    Glyph.Data = {
      36060000424D3606000000000000360400002800000020000000100000000100
      0800000000000002000000000000000000000001000000010000000000000000
      330000006600000099000000CC000000FF000033000000333300003366000033
      99000033CC000033FF00006600000066330000666600006699000066CC000066
      FF00009900000099330000996600009999000099CC000099FF0000CC000000CC
      330000CC660000CC990000CCCC0000CCFF0000FF000000FF330000FF660000FF
      990000FFCC0000FFFF00330000003300330033006600330099003300CC003300
      FF00333300003333330033336600333399003333CC003333FF00336600003366
      330033666600336699003366CC003366FF003399000033993300339966003399
      99003399CC003399FF0033CC000033CC330033CC660033CC990033CCCC0033CC
      FF0033FF000033FF330033FF660033FF990033FFCC0033FFFF00660000006600
      330066006600660099006600CC006600FF006633000066333300663366006633
      99006633CC006633FF00666600006666330066666600666699006666CC006666
      FF00669900006699330066996600669999006699CC006699FF0066CC000066CC
      330066CC660066CC990066CCCC0066CCFF0066FF000066FF330066FF660066FF
      990066FFCC0066FFFF00990000009900330099006600990099009900CC009900
      FF00993300009933330099336600993399009933CC009933FF00996600009966
      330099666600996699009966CC009966FF009999000099993300999966009999
      99009999CC009999FF0099CC000099CC330099CC660099CC990099CCCC0099CC
      FF0099FF000099FF330099FF660099FF990099FFCC0099FFFF00CC000000CC00
      3300CC006600CC009900CC00CC00CC00FF00CC330000CC333300CC336600CC33
      9900CC33CC00CC33FF00CC660000CC663300CC666600CC669900CC66CC00CC66
      FF00CC990000CC993300CC996600CC999900CC99CC00CC99FF00CCCC0000CCCC
      3300CCCC6600CCCC9900CCCCCC00CCCCFF00CCFF0000CCFF3300CCFF6600CCFF
      9900CCFFCC00CCFFFF00FF000000FF003300FF006600FF009900FF00CC00FF00
      FF00FF330000FF333300FF336600FF339900FF33CC00FF33FF00FF660000FF66
      3300FF666600FF669900FF66CC00FF66FF00FF990000FF993300FF996600FF99
      9900FF99CC00FF99FF00FFCC0000FFCC3300FFCC6600FFCC9900FFCCCC00FFCC
      FF00FFFF0000FFFF3300FFFF6600FFFF9900FFFFCC00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000ACACACACACAC
      ACACACACACACACACACACACACACACACACACACACACACACACACACACACACACACACAC
      ACACACACACACACACACACACACACACACACACACACACACACACACACACACACAC03ADAC
      ACACACACACAC03ADACACACACAC81D7D7ACACACACACACD7D7ACACACAC030505AD
      ACACACACAC0305ADACACACAC81ACACD7ACACACACAC81ACD7ACACACAC030505AD
      ACACACACAC03ADACACACACAC81ACACD7D7ACACACAC81D7ACACACACACAC030505
      ADACACAC0305ADACACACACAC8181ACACD7D7ACAC81ACD7ACACACACACACAC0305
      05ADAC0305ADACACACACACACAC8181ACACD7D781ACD7ACACACACACACACACAC03
      05050505ADACACACACACACACACAC8181ACACACACD7ACACACACACACACACACACAC
      030505ADACACACACACACACACACACAC8181ACACD7D7ACACACACACACACACACAC03
      05050505ADACACACACACACACACACAC81ACACACACD7ACACACACACACACACAC0305
      05ADAC0305ACACACACACACACACAC81ACACD78181D7D7D7ACACACACAC03030505
      ADACACAC0305ADACACACACAC8181ACACD7ACAC8181ACD7D7ACACAC03050505AD
      ACACACACAC0305ADACACAC81ACACACD7ACACACAC8181ACD7D7ACAC0305ADACAC
      ACACACACACAC0305ADACAC81ACD7D7ACACACACACAC8181ACD7ACACACACACACAC
      ACACACACACACACACACACAC8181ACACACACACACACACAC8181ACACACACACACACAC
      ACACACACACACACACACACACACACACACACACACACACACACACACACAC}
    NumGlyphs = 2
  end
end