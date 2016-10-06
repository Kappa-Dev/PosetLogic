let files = ref []
let formula_file = ref ""

let options = [
    ("-f", Arg.Set_string formula_file,
     "file name skeleton for outputs") ;]

let printf = Printf.printf

let test_membership t =
  let posets = Poset.get_posets t in
  let events = Poset.get_events t in
  let e1 = List.nth events 4 in
  let p1 = List.hd posets in

  let () = if (!Parameter.debug_mode) then
             ( printf "\n test_membership : event ";
               Poset.print_event e1; printf " in poset :\n ";
               Poset.print_poset p1) in

  let valuation x =
    match x with
    | "x" -> Poset.Ev(e1)
    | "y" -> Poset.Pos(p1)
    | _ -> failwith "uninterpreted variable" in
  let fm =
    (Formulas.Atom(Formulas.R("in", [Formulas.Var "x"; Formulas.Var "y"]))) in
  (valuation,fm)

let test_membership_const t =
  let posets = Poset.get_posets t in
  let events = Poset.get_events t in
  let e1 = List.nth events 4 in
  let p1 = List.hd posets in

  let () = if (!Parameter.debug_mode) then
             ( printf "\n test_membership : event ";
               Poset.print_event e1; printf " in poset :\n ";
               Poset.print_poset p1) in

  let valuation x =
    match x with
    | "x" -> Poset.Ev(e1)
    | _ -> failwith "uninterpreted variable" in
  let fm =
    (Formulas.Atom(
         Formulas.R(
             "in", [Formulas.Var "x"; Formulas.Const (Poset.Pos(p1))]))) in
  (valuation,fm)

let test_subset t =
  let posets = Poset.get_posets t in
  let p1 = List.nth posets 0 in
  let p2 = List.nth posets 3 in

  let () = if (!Parameter.debug_mode) then
             ( printf "\n test_subset : poset \n";
               Poset.print_poset p1; printf " in poset :\n ";
               Poset.print_poset p2) in

  let valuation x =
    match x with
    | "x" -> Poset.Pos(p1)
    | "y" -> Poset.Pos(p2)
    | _ -> failwith "uninterpreted variable" in
  let fm =
    (Formulas.Atom(
         Formulas.R("sub_posets", [Formulas.Var "x"; Formulas.Var "y"]))) in
  (valuation,fm)

let test_subset_without_obs t =
  let posets = Poset.get_posets t in
  let p1 = Poset.remove_obs(List.nth posets 3) in
  let p2 = Poset.remove_obs(List.nth posets 2) in

  let () = if (!Parameter.debug_mode) then
             ( printf "\n test_subset : poset \n";
               Poset.print_poset p1; printf " in poset :\n ";
               Poset.print_poset p2) in

  let valuation x =
    match x with
    | "x" -> Poset.Pos(p1)
    | "y" -> Poset.Pos(p2)
    | _ -> failwith "uninterpreted variable" in
  let fm =
    (Formulas.Atom(
         Formulas.R("sub_posets", [Formulas.Var "x"; Formulas.Var "y"]))) in
  (valuation,fm)

(* to do: test (forall p).test_intro_subset *)
let test_intro_subset t =
  let posets = Poset.get_posets t in
  let p1 = List.nth posets 2 in
  let valuation x =
    match x with
    | "x" -> Poset.Pos(p1)
    | _ -> failwith "uninterpreted variable" in
  let fm =
    (Formulas.Atom(
         Formulas.R("sub_posets",
                    [Formulas.Fn ("intro", [Formulas.Var "x"]);
                     Formulas.Var "x"]))) in
  (valuation,fm)

let test_forall_intro_subset t =
  let valuation x = failwith "uninterpreted variable" in
  let fm =
    (Formulas.Forall (
         "x",
         Formulas.Atom(
             Formulas.R("sub_posets",
                        [Formulas.Fn ("intro", [Formulas.Var "x"]);
                         Formulas.Var "x"])))) in
  (valuation,fm)

let test_events_labels_in_diff_posets t =
  let posets = Poset.get_posets t in
  let p1 = List.nth posets 1 in
  let e1 = List.nth (Poset.get_events_from_poset(p1)) 1 in
  let p2 = List.nth posets 2 in
  let e2 = List.nth (Poset.get_events_from_poset(p2)) 1 in

  let valuation x =
    match x with
    | "y1" -> Poset.Pos(p1)
    | "x1" -> Poset.Ev(e1)
    | "y2" -> Poset.Pos(p2)
    | "x2" -> Poset.Ev(e2)
    | _ -> failwith "uninterpreted variable" in
  let fm =
    (Formulas.And(
         Formulas.And(
             Formulas.Atom(
                 Formulas.R("in", [Formulas.Var "x1"; Formulas.Var "y1"])),
             Formulas.Atom(
                 Formulas.R("in", [Formulas.Var "x2"; Formulas.Var "y2"]))),
         Formulas.Atom(
             Formulas.R("equal_event_labels",
                        [Formulas.Var "x1"; Formulas.Var "x2"])))) in
  (valuation,fm)

let () =
  let () =
    Arg.parse
      options
      (fun f -> files := f::(!files))
      (Sys.argv.(0) ^
       " stories\n outil") in


  let posets = Poset.set_posets (!files) in
  let (func,pred,domain) = Formulas.interpretation posets in
  let (valuation,fm) = test_forall_intro_subset posets in
  ()
  (*
  if (Formulas.holds (func,pred,domain) valuation fm) then printf "true\n"
  else printf "false\n"
   *)
