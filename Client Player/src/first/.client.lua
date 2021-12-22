game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
game:GetService('StarterGui'):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)

repeat task.wait(.1) until game:IsLoaded()
script:Destroy()