open Arg;;
open Tcsargs;;
open Paritygame;;
open Arrayparitygame;;
  
module CommandLine =
struct
  let input_file = ref ""

  let obfuscate_nodes = ref true

  let obfuscate_edges = ref true

  let reverse_edges = ref false

  let speclist =  [(["--disablenodeobfuscation"; "-dn"], Unit(fun _ -> obfuscate_nodes := false),
                      "\n     keep ordering of nodes") ;
                   (["--disableedgeobfuscation"; "-de"], Unit(fun _ -> obfuscate_edges := false), 
                    "\n     keep ordering of edges"); (* TODO: does not make sense anymore. There is no explicit ordering visible to the outside. Option should probably be removed. *)
                   (["--justreverseedges"; "-rv"], Unit(fun _ -> obfuscate_edges := false; reverse_edges := true),
                    "\n     reverse edges (disables a previous `-de')")] (* TODO: same as above. `reverse' is also misleading. *)
                   
  let header = Info.get_title "Obfuscator Tool"
end ;;

open CommandLine ;;


let _ =
  SimpleArgs.parsedef speclist (fun f -> input_file := f) (header ^ "Usage: obfuscator [infile]\n" ^
                                              "Obfuscates the parity game given in <infile>. If this argument is omitted it reads a game from STDIN.");

  let in_channel = if !input_file = "" then stdin else open_in !input_file in

  let game = Parsers.parse_parity_game in_channel in

  let m = game#size  in
  let swap = Array.make m 0 in

  for i=0 to m-1 do
    swap.(i) <- i
  done;

  Random.self_init ();

  if !obfuscate_nodes then (
      for k=1 to 10*(m-1) do
        let i = Random.int m in
        let j = Random.int m in

        let x = swap.(i) in
        swap.(i) <- swap.(j);
        swap.(j) <- x
      done
  );

(*  print_string "Original game:\n";
  game#print;

  print_string "Swapping table:\n";
  Array.iteri (fun i -> fun j -> print_string ("  " ^ string_of_int i ^ " -> " ^ string_of_int j ^ "\n")) swap;
*)
  let game' = new array_pg m ~initFunc:(fun _ -> (0,plr_Even,[],None)) in

  game#iterate (fun i -> fun (p,pl,succs,_,name) -> let i' = swap.(i) in
						  game'#set_priority i' p;
						  game'#set_owner i' pl;
						  game'#set_desc i' name;
						  ns_iter (fun w -> game'#add_edge i' swap.(w)) succs);

(*  print_string "Obfuscated game:\n"; *)
  game'#print
