dans modules/crafting/server.lua ligne 236

				-- ajout de prod/fatigue/stress de truc: 

				local src = source
				local player = exports.qbx_core:GetPlayer(src)
				local playerjob = player.PlayerData.job.name
				print(player.PlayerData.charinfo.lastname.. " avec comme job " ..playerjob)

				if playerjob == 'cafet' then
					TriggerEvent('server:addProductivity', 0.2, src)
				elseif playerjob == 'it' then
					TriggerEvent('server:addProductivity', 0.5, src)
				elseif playerjob == 'infirmerie' then
					TriggerEvent('server:addProductivity', 0.5, src)
				else 
					TriggerEvent('server:addProductivity', 0.5, src)
				end