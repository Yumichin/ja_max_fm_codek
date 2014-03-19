/obj/structure/stairs/main
	name = "Stairs Trigger"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1.0
	unacidable = 1
	var/obj/structure/stairs/main/exit = null //�����
	var/obj/structure/stairs/main/sub = null //�������� ����
	var/obj/structure/stairs/main/subexit = null //�������� �����
	var/id = null


/obj/structure/stairs/exittrig
	name = "Stairs Exit"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1.0
	unacidable = 1
	var/id = null

/obj/structure/stairs/subtrig
	name = "Stairs Trigger Sub"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1.0
	unacidable = 1
	var/id = null

/obj/structure/stairs/subexittrig
	name = "Stairs Exit Sub"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1.0
	unacidable = 1
	var/id = null

/obj/structure/stairs/main/New()
	invisibility = 101    //��������� ��� ����
	spawn(8)
		for(var/obj/structure/stairs/exittrig/L in world)
			if(L.id == id)
				exit = L
				continue
		for(var/obj/structure/stairs/subtrig/K in world)
			if(K.id == id)
				sub = K
				continue
		for(var/obj/structure/stairs/subexittrig/N in world)       //����� �������� ���������
			if(N.id == id)
				subexit = N
				continue

/obj/structure/stairs/subtrig/New()
	invisibility = 101    //��������� ��� ����

/obj/structure/stairs/exittrig/New()
	invisibility = 101    //��������� ��� ����

/obj/structure/stairs/subexittrig/New()
	invisibility = 101    //��������� ��� ����


/obj/structure/stairs/main/HasEntered(atom/movable/M as mob|obj)  //������� ��������
	M.loc = get_turf(exit)                      //�������� ������������ �� �������
	var/turf/subT = get_turf(sub)
	for(var/atom/movable/ROI in subT)            //�������� ������� � ���-��������
		ROI.loc = get_turf(subexit)