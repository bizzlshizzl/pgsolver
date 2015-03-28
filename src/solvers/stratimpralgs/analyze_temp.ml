open Basics;;
open Stratimpralgs;;
open Paritygame;;
open Tcsset;;
open Tcsbasedata;;
open Univsolve;;
open Tcsarray;;
open Tcslist;;
open Tcsstrings;;


let next_bits bits =
	let keep = ref false in
	Array.init (Array.length bits) (fun i ->
		if !keep
		then bits.(i)
		else if bits.(i) = 1
		     then 0
				 else (
				   keep := true;
					 1
				 )
	);;

let zero_bits n = Array.make (n+1) 0;;

let up_bits bits = Array.init (Array.length bits) (fun i -> if i < Array.length bits - 1 then bits.(i + 1) else 0);;

let bits_mu bits =
	let rec helper i =
		if (bits.(i) = 0 || i == Array.length bits) then i else helper (i+1)
	in
	helper 0;; 

let mu_bits bits =
	let mu = bits_mu bits in
	Array.init (Array.length bits) (fun i -> if i = mu then 1 else bits.(i));;		

let bits_ptr bits =
	let next = Array.make (Array.length bits) None in
	for i = Array.length bits - 1 downto 0 do
		next.(i) <- if bits.(i) = 1 then Some i else next.(i+1);
	done;
	next;;   

		
		
let is_initial_strategy game strategy bits =
		let find x i = pg_find_desc game (Some (x ^ string_of_int i)) in
		let n = Array.length bits - 1 in
		let valid = ref "" in
		let v x y asrt =
			let r = if strategy.(x) = y then 1 else 0 in 
			if (r != asrt) then valid := !valid ^ (match pg_get_desc game x with None -> "" | Some y -> y) ^ ", ";
			()
		in
	  for i = 0 to n - 1 do
			v (find "m" i) (find "d" i) bits.(i);
			v (find "g" i) (find "c" i) (1 - bits.(i+1));
			if (i < n-1) then (
    			v (find "s" i) (find "u" i) bits.(i+1);
			);
			if (bits.(i) = 1) then (
   			v (find "d" i) (find "E" i) (1 - bits.(i+1));
				if (bits.(i+1) = 0) then (
     			v (find "a" i) (find "E" i) 1;
     			v (find "b" i) (find "E" i) 1;
				) else (
     			v (find "v" i) (find "X" i) 1;
     			v (find "w" i) (find "X" i) 1;
				)
			);
	  done;
		!valid = "";;
	

let is_phase_1 game strategy bits =
		let find x i = pg_find_desc game (Some (x ^ string_of_int i)) in
		let n = Array.length bits - 1 in
		let valid = ref "" in
		let v x y asrt =
			let r = if strategy.(x) = y then 1 else 0 in 
			if (r != asrt) then valid := !valid ^ (match pg_get_desc game x with None -> "" | Some y -> y) ^ ", ";
			()
		in
	  for i = 0 to n - 1 do
			v (find "m" i) (find "d" i) bits.(i);
			v (find "g" i) (find "c" i) (1 - bits.(i+1));
			if (i < n-1) then (
    			v (find "s" i) (find "u" i) bits.(i+1);
			);
			if (bits.(i) = 1) then (
   			v (find "d" i) (find "E" i) (1 - bits.(i+1));
				if (bits.(i+1) = 0) then (
     			v (find "a" i) (find "E" i) 1;
     			v (find "b" i) (find "E" i) 1;
				) else (
     			v (find "v" i) (find "X" i) 1;
     			v (find "w" i) (find "X" i) 1;
				)
			);
	  done;
		!valid;;
 

let is_phase_2 game strategy bits =
		let find x i = pg_find_desc game (Some (x ^ string_of_int i)) in
		let n = Array.length bits - 1 in
		let valid = ref "" in
		let v x y asrt =
			let r = if strategy.(x) = y then 1 else 0 in 
			if (r != asrt) then valid := !valid ^ (match pg_get_desc game x with None -> "" | Some y -> y) ^ ", ";
			()
		in
		let mu = bits_mu bits in
	  for i = 0 to n - 1 do
			if (i != mu && i != mu - 1) then v (find "m" i) (find "d" i) bits.(i);
			v (find "g" i) (find "c" i) (1 - bits.(i+1));
			if (i < n-1 && i != mu - 1) then (
    			v (find "s" i) (find "u" i) bits.(i+1);
			);
			if (bits.(i) = 1 || i = mu) then (
				if (i != mu) then v (find "d" i) (find "E" i) (1 - bits.(i+1));
				if (bits.(i+1) = 0) then (
     			v (find "a" i) (find "E" i) 1;
     			v (find "b" i) (find "E" i) 1;
				) else (
     			v (find "v" i) (find "X" i) 1;
     			v (find "w" i) (find "X" i) 1;
				)
			);
	  done;
		!valid;; 
	
	
let test_assumptions game strategy valu =
	let findf x = pg_find_desc game (Some x) in
	let find x = try pg_find_desc game (Some x) with Not_found -> failwith ("Not found: " ^ x ^ "\n") in
 	let leadsto i j =
		let (_, path, _) = valu.(i) in
		TreeSet.mem (j) path
	in
	let sigma_is s t = strategy.(find s) = find t in
	let n = ref 0 in
	while (try let _ = findf ("m" ^ string_of_int !n) in true with Not_found -> false) do incr n done;
	let n = !n in
	(* b_i never meets g_0, b_0, b_1 *)
	for i = 0 to n - 1 do
		let bi = find ("m" ^ string_of_int i) in
		let g0 = find ("d0") in
		let b0 = find ("m0") in
		let b1 = find ("m1") in
		if (i > 0 && leadsto bi g0) then print_string ("\n\nb_i to g_0\n\n");
		if (i > 0 && leadsto bi b0) then print_string ("\n\nb_i to b_0\n\n");
		if (i > 1 && leadsto bi b1) then print_string ("\n\nb_i to b_1\n\n");
		if (i < n-1) then (
			let si = find ("s" ^ string_of_int i) in
			if (strategy.(si) != b0) then (
				if (leadsto si g0) then print_string ("\n\ns_i to g_0\n\n");
				if (leadsto si g0) then print_string ("\n\ns_i to b_0\n\n");
				(*if (leadsto si b1) then print_string ("\n\ns_i to b_1\n\n");*)
			);
		);
	done;
	(* g_0 never sees b_0 *)
	let g0 = find ("d0") in
	let b0 = find ("m0") in
	let s0 = find ("s0") in
	if (leadsto g0 b0) then print_string ("\n\ng_0 to b_0\n\n");
	if (not (sigma_is "s0" "m0") && (leadsto s0 g0)) then print_string("\ncheck\n");;

	
let bitstrategyinfo game strategy valu =
	let findf x = pg_find_desc game (Some x) in
	let find x = try pg_find_desc game (Some x) with Not_found -> failwith ("Not found: " ^ x ^ "\n") in
	let sigma_is s t = strategy.(find s) = find t in
 	let leadsto i j =
		let (_, path, _) = valu.(i) in
		TreeSet.mem (j) path
	in
	let n = ref 0 in
	while (try let _ = findf ("m" ^ string_of_int !n) in true with Not_found -> false) do incr n done;
	let n = !n in
	let bitinfo = Array.make n (false, false) in (* good, set *)
	for i = n - 1 downto 0 do
		if (sigma_is ("m" ^ string_of_int i) ("d" ^ string_of_int i)) then (
			if (i = n-1) then (
				bitinfo.(i) <- (true, true)
			) else (
				if (leadsto (find ("m" ^ string_of_int i)) (find ("c" ^ string_of_int i)))
				then let (is_good, is_set) = bitinfo.(i+1) in bitinfo.(i) <- (not is_set, true)
				else if (leadsto (find ("m" ^ string_of_int i)) (find ("d" ^ string_of_int (i+1))))
				then let (is_good, is_set) = bitinfo.(i+1) in bitinfo.(i) <- (is_set && is_good, true)
				else bitinfo.(i) <- (false, true)
			)
		) else (
			bitinfo.(i) <- (true, false)
		)
	done;
	bitinfo;;
	
let strategy_mu game strategy valu =
	let bitinfo =	bitstrategyinfo game strategy valu in
	let all_good = ref true in
	let n = Array.length bitinfo in
	let least_good_one = ref n in
	let least_good_zero = ref n in
	for i = n - 1 downto 0 do
		let (is_good, is_set) = bitinfo.(i) in
		all_good := !all_good && is_good;
		if (is_good && is_set) then least_good_one := i;
		if (is_good && not is_set) then least_good_zero := i;
	done;
	if (!all_good) then !least_good_zero else !least_good_one;;


let test_valuation_assumptions game strategy valu bits n =	
	let bitinfo = bitstrategyinfo game strategy valu in
	let find x = try pg_find_desc game (Some x) with Not_found -> failwith ("Not found: " ^ x ^ "\n") in
	let sigma_is s t = strategy.(find s) = find t in
	let sigmis s i t j = sigma_is (s ^ string_of_int i) (if j >= 0 then t ^ string_of_int j else t) in
	let mbits = Array.init (n+1) (fun i -> if i < n && (sigma_is ("m" ^ string_of_int i) ("d" ^ string_of_int i)) then 1 else 0) in
	let node_valu u =
		let (_, v_valu, _) = valu.(u) in v_valu
  in
	let empty_valu =
		TreeSet.empty (TreeSet.get_compare (node_valu 0))
	in  
	let filter_valu va p =
		TreeSet.filter (fun u ->pg_get_pr game u >= p) va
	in
	let diff_valu va1 va2 p =
		TreeSet.sym_diff (filter_valu va1 p) (filter_valu va2 p)
	in
	let check_valu s va1 va2 p =
		let ff = TreeSet.format (fun i -> OptionUtils.get_some (pg_get_desc game i)) in
		let va1 = filter_valu va1 p in
		let va2 = filter_valu va2 p in
		let diff = diff_valu va1 va2 p in
		if (not (TreeSet.is_empty diff)) then (
			print_string ("\n\n" ^ s ^ " " ^ ArrayUtils.format string_of_int bits ^ " " ^ ArrayUtils.format string_of_int mbits ^ " " ^ ff diff ^ " | " ^ ff va1 ^ " | " ^ ff va2 ^ "\n\n")
		)
	in
	let l = bits_mu bits in
	let k = strategy_mu game strategy valu in
(*	if (k != l) then
		print_string ("\n\n" ^ "!!! " ^ ArrayUtils.format string_of_int bits ^ " " ^ ArrayUtils.format string_of_int mbits ^ " "^ string_of_int k ^ " " ^ string_of_int l ^ "\n\n");*)
		
	let add_walkthrough nodes j =
		let temp = ref nodes in
			temp := TreeSet.add (find ("d" ^ string_of_int j) ) !temp;
			if sigma_is ("d" ^ string_of_int j) ("E" ^ string_of_int j)  then
				temp := TreeSet.add (find ("c" ^ string_of_int j) ) !temp
			else
				temp := TreeSet.add (find ("z" ^ string_of_int j) ) !temp;
		!temp
	in
		
	let left_b_valus = Array.make (n+1) (TreeSet.add (find "Y") empty_valu) in
	let right_b_valus = Array.make (n+1) (TreeSet.add (find "Y") empty_valu) in
	for i = n - 1 downto 0 do
		left_b_valus.(i) <- left_b_valus.(i+1);
		if (mbits.(i) = 1)
		then left_b_valus.(i) <- add_walkthrough left_b_valus.(i) i;
		right_b_valus.(i) <- right_b_valus.(i+1);
		if (i != k && (mbits.(i) = 1 || i < k))
		then right_b_valus.(i) <- add_walkthrough right_b_valus.(i) i
	done;
		
	let bvalus = Array.init (n+2) (fun i -> if i >= n then (TreeSet.add (find "Y") empty_valu) else if mbits.(i) = 0 || i = k then left_b_valus.(i) else right_b_valus.(i)) in
	let s = ref n in
	for i = n - 1 downto 0 do
	  if (mbits.(i) = 0)
		then s := i
  done;
	let s = !s in

	let r = ref (n-2) in
	for i = n - 2 downto 0 do
	  if mbits.(i) = 0 && (
		    sigma_is ("d" ^ string_of_int i) ("E" ^ string_of_int i) ||
				sigma_is ("s" ^ string_of_int i) ("m0") ||
				not (fst bitinfo.(i+1)) 		   
		)
		then r := i
  done;
	let r = !r in
	let t_test = (sigma_is ("d" ^ string_of_int r) ("E" ^ string_of_int r) && sigma_is ("g" ^ string_of_int r) ("m0")) ||
		(sigma_is ("d" ^ string_of_int r) ("X" ^ string_of_int r) && sigma_is ("s" ^ string_of_int r) ("m0"))  in
	let dvalusy = Array.init (r+1) (fun i ->
		let temp = ref (if r+2 >= n then TreeSet.add (find "Y") empty_valu else bvalus.(r+2)) in
		temp := TreeSet.add (find ("d" ^ string_of_int r) ) !temp;
		temp := TreeSet.add (find ("c" ^ string_of_int r) ) !temp;
		for j = i to r - 1 do
			temp := TreeSet.add (find ("d" ^ string_of_int j) ) !temp;
			temp := TreeSet.add (find ("z" ^ string_of_int j) ) !temp;
		done;
		!temp
	) in
	let dvalusx = Array.init (r+1) (fun i ->
		let temp = ref (bvalus.(0)) in
		temp := TreeSet.add (find ("d" ^ string_of_int r) ) !temp;
		for j = i to r - 1 do
			temp := TreeSet.add (find ("d" ^ string_of_int j) ) !temp;
			temp := TreeSet.add (find ("z" ^ string_of_int j) ) !temp;
		done;
		!temp
	) in
	let svalus = Array.init (n-1) (fun i ->
			if sigma_is ("s" ^ string_of_int i) ("m0")
			then bvalus.(0)
			else if mbits.(i+1) = 1 || i >= r
			then TreeSet.add (find ("z" ^ string_of_int i)) bvalus.(i+1)
			else if s != 0 || not t_test
			then TreeSet.add (find ("z" ^ string_of_int i) ) dvalusy.(i+1)
			else TreeSet.add (find ("z" ^ string_of_int i) ) dvalusx.(i+1)
	) in
	let gvalus = Array.init n (fun i -> if sigma_is ("g" ^ string_of_int i) ("m0") then bvalus.(0) else TreeSet.add (find ("c" ^ string_of_int i)) bvalus.(i+2)) in
	let d_zero = ref (TreeSet.add (find "d0") (TreeSet.add (find "Y") empty_valu)) in
	let d_comp i =
		if (sigma_is ("d" ^ string_of_int i) ("E" ^ string_of_int i)) && (sigma_is ("a" ^ string_of_int i) ("E" ^ string_of_int i)) && (sigma_is ("b" ^ string_of_int i) ("E" ^ string_of_int i))
		then TreeSet.add (find ("d" ^ string_of_int i)) gvalus.(i)
		else if i < n-1 && (sigma_is ("d" ^ string_of_int i) ("X" ^ string_of_int i)) && (sigma_is ("w" ^ string_of_int i) ("X" ^ string_of_int i)) && (sigma_is ("v" ^ string_of_int i) ("X" ^ string_of_int i))
		then TreeSet.add (find ("d" ^ string_of_int i)) svalus.(i)
		else
		if mbits.(i) = 1 || (i > r && not (sigma_is ("s" ^ string_of_int (i-1)) ("m0")))
		then bvalus.(i)
		else if (i > 0) && not (sigma_is ("s" ^ string_of_int (i-1)) ("m0")) then (
			if s != 0 || not t_test
			then dvalusy.(i)
			else dvalusx.(i)
		)
		else if i < n-1 && (sigma_is ("d" ^ string_of_int i) ("X" ^ string_of_int i)) && (not (sigma_is ("s" ^ string_of_int i) ("m0"))) && mbits.(i+1) = 0
		then TreeSet.add (find ("d" ^ string_of_int i)) svalus.(i)
		else if (sigma_is ("d" ^ string_of_int i) ("E" ^ string_of_int i)) && not (sigma_is ("g" ^ string_of_int i) ("m0")) && i = l-1 && mbits.(l) = 1
		then TreeSet.add (find ("d" ^ string_of_int i)) gvalus.(i)
	  else if i = 0
		then TreeSet.add (find ("d" ^ string_of_int i)) bvalus.(1)

		else (
			 let reachable_d0 = ((sigmis "d" i "E" i) && (((sigmis "o" i "d" 0) && (sigmis "a" i "o" i || sigmis "b" i "o" i)) || ((sigmis "p" i "d" 0) && (sigmis "a" i "p" i || sigmis "b" i "p" i)))) ||
              (i < n-1 && ((sigmis "d" i "X" i) && (((sigmis "q" i "d" 0) && (sigmis "v" i "q" i || sigmis "w" i "q" i)) || ((sigmis "r" i "d" 0) && (sigmis "v" i "r" i || sigmis "w" i "r" i))))) in
			 let reachable_m1 = ((sigmis "d" i "E" i) && (((sigmis "o" i "m" 1) && (sigmis "a" i "o" i || sigmis "b" i "o" i)) || ((sigmis "p" i "m" 1) && (sigmis "a" i "p" i || sigmis "b" i "p" i)))) ||
              (i < n-1 && ((sigmis "d" i "X" i) && (((sigmis "q" i "m" 1) && (sigmis "v" i "q" i || sigmis "w" i "q" i)) || ((sigmis "r" i "m" 1) && (sigmis "v" i "r" i || sigmis "w" i "r" i))))) in
			 let reachable_y = ((sigmis "d" i "E" i) && ((sigmis "a" i "Y" (-1)) || (sigmis "b" i "Y" (-1)) || ((sigmis "o" i "Y" (-1)) && (sigmis "a" i "o" i || sigmis "b" i "o" i)) || ((sigmis "p" i "Y" (-1)) && (sigmis "a" i "p" i || sigmis "b" i "p" i)))) ||
			       (i < n-1 && ((sigmis "d" i "X" i) && ((sigmis "v" i "Y" (-1)) || (sigmis "w" i "Y" (-1)) || ((sigmis "q" i "Y" (-1)) && (sigmis "v" i "q" i || sigmis "w" i "q" i)) || ((sigmis "r" i "Y" (-1)) && (sigmis "v" i "r" i || sigmis "w" i "r" i))))) in

	  if (reachable_y)
		then TreeSet.add (find ("d" ^ string_of_int i))(TreeSet.add (find "Y") empty_valu)
		
		else if mbits.(0) = 0 && not reachable_d0
		then TreeSet.add (find ("d" ^ string_of_int i)) bvalus.(1)
		
		else if mbits.(0) = 1 && not reachable_m1
		then TreeSet.add (find ("d" ^ string_of_int i)) !d_zero
		
		else if mbits.(0) = 1 && not (fst bitinfo.(0))
		then TreeSet.add (find ("d" ^ string_of_int i)) !d_zero
		
		else if mbits.(0) = 0 && k = 0 && not ((sigmis "d" 0 "E" 0 && sigmis "a" 0 "E" 0 && sigmis "b" 0 "E" 0) || (sigmis "d" 0 "X" 0 && sigmis "v" 0 "X" 0 && sigmis "w" 0 "X" 0))
		then TreeSet.add (find ("d" ^ string_of_int i)) !d_zero

		else TreeSet.add (find ("d" ^ string_of_int i)) bvalus.(1)
		)
	in
	d_zero := d_comp 0;
	let dvalus = Array.init n (fun i ->
		d_comp i
	) in
	for i = 0 to n - 1 do
				check_valu ("ladder " ^ string_of_int i ^ " (mu=" ^ string_of_int k ^ ") ") (node_valu (find ("m" ^ string_of_int i))) bvalus.(i) 11;

				check_valu ("left_up " ^ string_of_int i ^ " (mu=" ^ string_of_int k ^ ") ") (node_valu (find ("g" ^ string_of_int i))) gvalus.(i) 11;

				if (i < n-1)
				then check_valu ("right_up " ^ string_of_int i ^ " (mu=" ^ string_of_int k ^ ") ") (node_valu (find ("s" ^ string_of_int i))) svalus.(i) 11;
				
				check_valu ("bisel " ^ string_of_int i ^ " (mu=" ^ string_of_int k ^ ") ") (node_valu (find ("d" ^ string_of_int i))) dvalus.(i) 11;
 	  done;;
	
	
	



(*

	
	
	
let my_count_sub_exp = ref 0
let last_check_sub_exp = ref ""


let active_of bits = Array.init (Array.length bits) (fun i -> if i < Array.length bits - 1 && bits.(i+1) = 1 then 1 else 0) 
	
let test_state game strategy =
	let find x = pg_find_desc game (Some x) in
	let check x i y j = strategy.(find(x ^ string_of_int i)) = find(y ^ string_of_int j) in
	let n = ref 0 in
	while (try let _ = find ("m" ^ string_of_int !n) in true with Not_found -> false) do incr n done;
	let n = !n in
	let valid = ref true in
  let bits = Array.make n 0 in
	let active = Array.make n 0 in
  for i = 0 to n - 1 do
		bits.(i) <- if check "m" i "d" i then 1 else 0;
		active.(i) <- if check "d" i "E" i then 0 else 1;
	done;
	for i = 1 to n - 1 do
		if (bits.(i) = 1) then (
			if active.(i) = 0 then (
				if not (check "d" i "E" i) then valid := false;
				if i < n-1 && (check "g" i "m" 0) then valid := false;
				if i < n-1 && not(check "s" i "m" 0) then valid := false;
				if not(check "a" i "E" i) then valid := false;
				if not(check "b" i "E" i) then valid := false;
			) else if active.(i) = 1 then (
				if (check "d" i "E" i) then valid := false;
				if i < n-1 && not(check "g" i "m" 0) then valid := false;
				if i < n-1 && (check "s" i "m" 0) then valid := false;
				if not(check "w" i "X" i) then valid := false;
				if not(check "v" i "X" i) then valid := false;
			)
		);
	done;
	if !valid then Some (Array.to_list bits) else None;;
let old_state = ref None;;
	
	
let fair_exp_get_bit_state game strategy =
	let find x = pg_find_desc game (Some x) in
	let check x i y j = strategy.(find(x ^ string_of_int i)) = find(y ^ string_of_int j) in
	let n = ref 0 in
	while (try let _ = find ("m" ^ string_of_int !n) in true with Not_found -> false) do incr n done;
	let n = !n in
  let bits = Array.make n 0 in
  for i = 0 to n - 1 do
		bits.(i) <- if check "m" i "d" i then 1 else 0
	done;
	let active = active_of bits in
	let valid = ref true in
	for i = 0 to n - 1 do
		if active.(i) = 0 then (
			if bits.(i)=1 && not (check "d" i "E" i) then valid := false;
			if i < n-1 && (check "g" i "m" 0) then valid := false;
			if i < n-1 && not(check "s" i "m" 0) then valid := false;
			if bits.(i)=1 && not(check "a" i "E" i) then valid := false;
			if bits.(i)=1 && not(check "b" i "E" i) then valid := false;
		) else if active.(i) = 1 then (
			if bits.(i)=1 && (check "d" i "E" i) then valid := false;
			if i < n-1 && not(check "g" i "m" 0) then valid := false;
			if i < n-1 && (check "s" i "m" 0) then valid := false;
			if bits.(i)=1 && not(check "w" i "X" i) then valid := false;
			if bits.(i)=1 && not(check "v" i "X" i) then valid := false;
		)
	done;
	if !valid then Some (Array.to_list bits) else None;;


let test_assumptions game strategy valu =
	let findf x = pg_find_desc game (Some x) in
	let find x = try pg_find_desc game (Some x) with Not_found -> failwith ("Not found: " ^ x ^ "\n") in
 	let leadsto i j =
		let (_, path, _) = valu.(i) in
		TreeSet.mem (j) path
	in
	let sigma_is s t = strategy.(find s) = find t in
	let n = ref 0 in
	while (try let _ = findf ("m" ^ string_of_int !n) in true with Not_found -> false) do incr n done;
	let n = !n in
	(* b_i never meets g_0, b_0, b_1 *)
	for i = 1 to n - 1 do
		let bi = find ("m" ^ string_of_int i) in
		let g0 = find ("d0") in
		let b0 = find ("m0") in
		let b1 = find ("m1") in
		if (leadsto bi g0) then print_string ("\n\nb_i to g_0\n\n");
		if (leadsto bi b0) then print_string ("\n\nb_i to b_0\n\n");
		if (i > 1 && leadsto bi b1) then print_string ("\n\nb_i to b_1\n\n");
	done;
	(* g_0 never sees b_0 *)
	let g0 = find ("d0") in
	let b0 = find ("m0") in
	if (leadsto g0 b0) then print_string ("\n\ng_0 to b_0\n\n");
	
	let valu_empty = TreeSet.empty (TreeSet.get_compare (let (_, x, _) = valu.(0) in x)) in
	let valu_single = TreeSet.singleton (TreeSet.get_compare (let (_, x, _) = valu.(0) in x)) in
  let rec b_sigma_i i =
		if i >= n then valu_empty
		else TreeSet.union (if not (sigma_is ("m" ^ string_of_int i) ("d" ^ string_of_int i)) then b_sigma_i (i+1) else valu_empty)
		                    (if (sigma_is ("m" ^ string_of_int i) ("d" ^ string_of_int i)) then g_sigma_i i else valu_empty)
	and g_sigma_i i =
		if i >= n then valu_empty
		else TreeSet.union (valu_single (find ("d" ^ string_of_int i ))) (
			TreeSet.union (if leadsto (find ("d" ^ string_of_int i)) (find ("c" ^ string_of_int i)) then (TreeSet.union (valu_single (find ("c" ^ string_of_int i ))) (b_sigma_i (i+2))) else valu_empty)
			               (if i < n - 1 && leadsto (find ("d" ^ string_of_int i)) (find ("z" ^ string_of_int i)) then (TreeSet.union (valu_single (find ("z" ^ string_of_int i ))) (g_sigma_i (i+1))) else valu_empty)
		)  
  in
	let combi_sigma_i i = TreeSet.union (TreeSet.union (g_sigma_i i)
	                                                     (if leadsto (find ("d" ^ string_of_int i)) (find ("d0")) then g_sigma_i 0 else valu_empty))
	                                     (TreeSet.union (if leadsto (find ("d" ^ string_of_int i)) (find ("m0")) then b_sigma_i 0 else valu_empty)
																			                 (if not (leadsto (find ("d" ^ string_of_int i)) (find ("m0"))) && leadsto (find ("d" ^ string_of_int i)) (find ("m1")) then b_sigma_i 1 else valu_empty))
	in
	let filter_valu i = 
    let (_, path, _) = valu.(i) in
		TreeSet.filter (fun i -> pg_get_pr game i > 10 && i != find "Y") path
	in
	for i = 0 to n - 1 do
		if (not (TreeSet.equal (filter_valu (find ("m" ^ string_of_int i))) (b_sigma_i i))) then (
			print_string ((TreeSet.format string_of_int (filter_valu (find ("m" ^ string_of_int i)))) ^ " vs " ^ (TreeSet.format string_of_int (b_sigma_i i)) ^ "\n");
		);
	done;
	for i = 0 to n - 1 do
		if (not (TreeSet.equal (filter_valu (find ("d" ^ string_of_int i))) (combi_sigma_i i))) then (
			print_string ((TreeSet.format string_of_int (filter_valu (find ("d" ^ string_of_int i)))) ^ " vs " ^ (TreeSet.format string_of_int (combi_sigma_i i)) ^ "\n");
		);
	done;
	( *
	let cmp_valu x y = node_valuation_ordering game node_total_ordering_by_position valu.(x) valu.(y) in
	let cmp_inner x y = node_valuation_ordering game node_total_ordering_by_position (find "Z", x, 0) (find "Z", y, 0) in
	let iff a b = (a && b) || ((not a) && (not b)) in
	let niff a b = not (iff a b) in
	let counter = compute_counter_strategy game strategy in
	let next x = if (strategy.(x) != -1) then strategy.(x) else counter.(x) in
	let rec reset x =
			let y = String.get (match (pg_get_desc game x) with Some s -> s | None -> "Z") 0 in
			if (y = 'Z' || y = 'm' || y = 'd') then x else reset (next x)
	in 
	for i = 0 to n - 2 do
		if niff (cmp_valu (find ("E" ^ string_of_int i)) (find ("X" ^ string_of_int i)) > 0)
		        (cmp_valu (reset (find ("E" ^ string_of_int i))) (reset(find ("X" ^ string_of_int i))) >= 0)
						then print_string ("error\n");
	done;
	* )
 ();;


let old_state = ref None;;
let state_counter = ref 0;;

let models_scheme scheme bits = TreeSet.for_all (fun (i,j) -> (if i < Array.length bits then bits.(i) else 0) = j) scheme
let bits_to_int arr = Array.fold_right (fun b acc -> 2 * acc + b) arr 0
let int_to_bits i = let rec h i = if i = 0 then [] else (i mod 2)::h (i/2) in Array.of_list (h i)
let leq_bits bits = TreeSet.of_array_def (Array.init (bits_to_int bits + 1) int_to_bits)
let match_set bits scheme = TreeSet.filter (models_scheme scheme) (leq_bits bits)
let flip_set bits i scheme = match_set bits (TreeSet.union (TreeSet.add (i,1) scheme) (TreeSet.of_array_def (Array.init i (fun j -> (j, 0)))))
let unflip_set bits i scheme = match_set bits (TreeSet.union (TreeSet.add (i,0) scheme) (TreeSet.of_array_def (Array.init i (fun j -> (j, 0)))))
let bit_flips bits i scheme = TreeSet.cardinal (flip_set bits i scheme)
let bit_unflips bits i scheme = TreeSet.cardinal (unflip_set bits i scheme)
let max_flip_number bits i scheme = TreeSet.max_elt (TreeSet.add 0 (TreeSet.map2_def bits_to_int (flip_set bits i scheme)))
let max_unflip_number bits i scheme = TreeSet.max_elt (TreeSet.add 0 (TreeSet.map2_def bits_to_int (unflip_set bits i scheme)))

let check_fair_exp_occ game strategy bits occ =
		let find x i = pg_find_desc game (Some (x ^ string_of_int i)) in
		let get x i y j = let (a,b) = (find x i,find y j) in occ.(a).(pg_get_tr_index_of game a b) in
		let n = Array.length bits in
		let valid = ref true in
		let active = active_of bits in
		let assrt x i y j k s f =
			let g = get x i y j in
			if f g then true else (
				print_string ("\n\n" ^ x ^ string_of_int i ^ " " ^ y ^ string_of_int j ^ " : " ^ string_of_int g ^ s ^ string_of_int k ^ "\n\n");
				false
			) in
		let eqs x i y j k = assrt x i y j k "=" (fun a -> a = k) in
		let bounded x i y j k l = assrt x i y j k ">=" (fun a -> a >= k) && assrt x i y j l "<=" (fun a -> a <= l) in
		let bits_as_int = bits_to_int bits in
		for i = 0 to n - 1 do
			let ibfl = bit_flips bits i TreeSet.empty_def in
			let ibflh = ibfl / 2 in
			let zbfl = bit_flips bits 0 TreeSet.empty_def in
 			let ipbfl = if i < n-1 then bit_flips bits (i+1) TreeSet.empty_def else 0 in
			let ibfla0 = max_flip_number bits i (TreeSet.singleton_def (i+1, 0)) in
			let ibfla1 = max_flip_number bits i (TreeSet.singleton_def (i+1, 1)) in
			let ipbmfl = if i < n-1 then max_flip_number bits (i+1) TreeSet.empty_def else 0 in
			let ipbmflu = if i < n-1 then max_unflip_number bits (i+1) TreeSet.empty_def else 0 in
			
			valid := eqs "m" i "d" i ibfl && !valid;

			if (bits.(i) = 1 && active.(i) = 0) then (
				valid := eqs "a" i "E" i (ibfla0/2 + ibfla0 mod 2) && !valid;
				valid := eqs "a" i "o" i (ibfla0/2) && !valid;
        valid := bounded "b" i "E" i (ibfla0/2) (ibfla0/2 + 1) && !valid;
        valid := bounded "b" i "p" i (ibfla0/2 - 1) (ibfla0/2) && !valid;
			  valid := eqs "o" i "d" 0 zbfl && !valid;
			  valid := eqs "p" i "d" 0 zbfl && !valid;
			  valid := bounded "o" i "m" 1 (zbfl-1) zbfl && !valid;
			  valid := bounded "p" i "m" 1 (zbfl-1) zbfl && !valid;
			) else (
				let limit = min ((ibfla0/2) + bits_as_int - ipbmfl) zbfl in
				valid := bounded "a" i "E" i (limit - 1) (limit + 1) && !valid;
				valid := bounded "b" i "E" i (limit - 1) (limit + 1) && !valid;
				valid := bounded "a" i "o" i (limit - 1) (limit + 1) && !valid;
				valid := bounded "b" i "p" i (limit - 1) (limit + 1) && !valid;
				valid := bounded "o" i "d" 0 (zbfl-1) zbfl && !valid;
				valid := bounded "p" i "d" 0 (zbfl-1) zbfl && !valid;
				valid := bounded "o" i "m" 1 (zbfl-1) zbfl && !valid;
				valid := bounded "p" i "m" 1 (zbfl-1) zbfl && !valid;
	  	);

			
			if (i < n-1) then (
				
				valid := eqs "m" i "m" (i+1) (ibfl - bits.(i)) && !valid;
				valid := eqs "g" i "c" i (ipbfl - 1 * bits.(i+1)) && !valid;
				valid := eqs "s" i "u" i (ipbfl - 0 * bits.(i+1)) && !valid;
				valid := eqs "g" i "m" 0 (ipbfl - 0 * bits.(i+1)) && !valid;
				valid := eqs "s" i "m" 0 (ipbfl - 1 * bits.(i+1)) && !valid;
				if (bits.(i) = 1 && active.(i) = 1) then (
          valid := eqs "v" i "X" i (ibfla1/2 + ibfla1 mod 2) && !valid;
          valid := eqs "w" i "X" i (ibfla1/2) && !valid;
	        valid := bounded "v" i "r" i (ibfla1/2 - 1) (ibfla1/2) && !valid;
	        valid := bounded "w" i "q" i (ibfla1/2 - 1) (ibfla1/2) && !valid;
					valid := eqs "q" i "d" 0 zbfl && !valid;
				  valid := eqs "r" i "d" 0 zbfl && !valid;
					valid := bounded "q" i "m" 1 (zbfl-1) zbfl && !valid;
				  valid := bounded "r" i "m" 1 (zbfl-1) zbfl && !valid;
				) else (
				  let limit = min ((ibfla1/2) + bits_as_int - ipbmflu) zbfl in
					valid := bounded "v" i "X" i (limit - 1) (limit + 1) && !valid;
					valid := bounded "w" i "X" i (limit - 1) (limit + 1) && !valid; 
					valid := bounded "v" i "r" i (limit - 1) (limit + 1) && !valid;
					valid := bounded "w" i "q" i (limit - 1) (limit + 1) && !valid; 
					valid := bounded "q" i "d" 0 (zbfl-1) zbfl && !valid;
					valid := bounded "r" i "d" 0 (zbfl-1) zbfl && !valid;
					valid := bounded "q" i "m" 1 (zbfl-1) zbfl && !valid;
					valid := bounded "r" i "m" 1 (zbfl-1) zbfl && !valid;
				);

				valid := bounded "d" i "E" i (ibflh - 1) (get "a" i "E" i) && !valid;
				valid := bounded "d" i "X" i (ibflh - 1) (get "v" i "X" i) && !valid;

			);
		done;
( *				print_string (ArrayUtils.format string_of_int bits ^ " " ^ string_of_int bits_as_int ^ " " ^ string_of_int (get "d" 4 "E" 4) ^ " " ^ string_of_int (get "a" 4 "E" 4) ^ "\n"); * )
		!valid;;
*)

let curbits = ref [||] ;;
let old_phase = ref "";;
let iteration = ref 0;;
let last_active_phases = ref TreeSet.empty_def;;

let switch_zadeh_exp_tie_break_callback n game old_strategy valu v w r s =

		let msg_tagged_nl v = message_autotagged_newline v (fun _ -> "ANALYZE") in

		if (Array.length !curbits = 0)
		then curbits := zero_bits n;
		
	  if (not (is_initial_strategy game old_strategy !curbits) && (is_initial_strategy game old_strategy (next_bits !curbits)))
		then (
			curbits := next_bits !curbits;
			msg_tagged_nl 1 (fun _ -> "--------------------------------------------------\n");
			last_active_phases := TreeSet.empty_def;
		);
		
		test_assumptions game old_strategy valu;
		test_valuation_assumptions game old_strategy valu !curbits n;
		(*
		let focus = [("m", "M M M ----"); ("d", "D D D ----"); ("g", "G G G ----"); ("s", "S S S ----");
		             ("a", "- -"); ("b", "- -"); ("v", "- -"); ("w", "- -");
								 ("o", "o"); ("p", "o"); ("q", "o"); ("r", "o")
		] in
		
		let phases = [(*
			("p1", is_phase_1);
			("p2", is_phase_2)*)
		] in
		let active_phases = ref TreeSet.empty_def in
		let inactive_phases = ref [] in
		List.iter (fun (p, f) ->
			let s = f game old_strategy !curbits in
			if s = ""
			then active_phases := TreeSet.add p !active_phases
			else inactive_phases := (p, s)::!inactive_phases
		) phases;
		let inactive_now = List.filter (fun (p, _) -> TreeSet.mem p !last_active_phases) !inactive_phases in
		last_active_phases := !active_phases;		
		
		let has_focus = ref None in
		List.iter (fun (x, t) ->
			let y = OptionUtils.get_some (pg_get_desc game v) in
			if String.sub y 0 (String.length x) = x
			then has_focus := Some t
	  ) focus;
		
		msg_tagged_nl 1 (fun _ ->
			ListUtils.format string_of_int (List.rev (Array.to_list !curbits)) ^ " : " ^
			TreeSet.format (fun p -> p) !active_phases ^ " -- " ^
		  ListUtils.format (fun (p, s) -> p ^ ":" ^ s) inactive_now ^ 
			" -- " ^ OptionUtils.get_some (pg_get_desc game v) ^ "->" ^ OptionUtils.get_some (pg_get_desc game w) ^
			(if !has_focus != None then " " ^ OptionUtils.get_some !has_focus else "") ^ 
			"\n"
		);*)
		

		(*
  let state = fair_exp_get_bit_state game old_strategy in
	if (compare state !old_state != 0) then (
		old_state := state;
		match state with None -> (
			msg_tagged_nl 1 (fun _ -> "\nFail\n");
		) | Some b -> (
			incr state_counter;
			msg_tagged_nl 1 (fun _ -> "\n" ^ ListUtils.format string_of_int b ^ " --" ^ string_of_int !state_counter ^ "\n");
			let check = check_fair_exp_occ game old_strategy (Array.of_list b) occ in
			msg_tagged_nl 1 (fun _ -> ListUtils.format string_of_int b ^ " - " ^ string_of_int (bits_to_int (Array.of_list b)) ^ " - " ^ (if check then "yes" else "no") ^ "\n");
		)
	); *)
	(*
	test_assumptions game old_strategy valu;
	*)
   (*


let is_next = ref false in
if (compare (is_phase_1 game old_strategy (next_bits !curbits) (next_bits (next_bits !curbits))) "" = 0) then (
	curbits := next_bits !curbits;
	is_next := true;
);
let rr = ref "" in
for i = 0 to n - 1 do
	rr := (if !curbits.(i) = 1 then "1" else "0") ^ !rr;
done;
let nextbits = next_bits !curbits in
	incr iteration;
let phase = is_phase_1 game old_strategy !curbits nextbits in
let phase = if compare phase "" = 0 then phase else is_phase_1 game old_strategy nextbits (next_bits nextbits) in

is_next := !is_next || (compare phase !old_phase != 0);
old_phase := phase;
 if (!is_next) then msg_tagged_nl 1 (fun _ -> "\n\rState " ^ string_of_int !my_count_sub_exp ^ ": " ^ r  ^ " -- phase " ^ phase ^ " -- " ^ !rr ^ " / " ^ string_of_int !iteration ^ "\n"); 
(*
if !last_check_sub_exp <> !r && is_phase_1 game old_strategy state' then (
 msg_tagged_nl 1 (fun _ -> "\n\rState " ^ string_of_int !my_count_sub_exp ^ ": " ^ !r  ^ "        \n");    
		last_check_sub_exp := !r;
		incr my_count_sub_exp;
	);	*)
	(*
	if !last_check_sub_exp <> !r then (
		last_check_sub_exp := !r;
		incr my_count_sub_exp;
	);*)
    msg_tagged_nl 3 (fun _ -> "\n\rState: " ^ s ^ " / " (*^ !t ^ " / "*) ^ r ^ " = " ^ string_of_int !my_count_sub_exp ^ "        \n");
*)