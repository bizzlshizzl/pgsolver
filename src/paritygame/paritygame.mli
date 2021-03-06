(** Module containing everything related to paritygame.  TODO
    This includes:
      - nodes
      - nodeset
      - nodeset structure
      - player/priority
      - node ordering
      - solution
      - strategy
      - partial paritygames
      - dynamic paritygames
      - decomposition
      - paritygame "template" (virtual class)
      - global solver

    In general, from all of the above, functions that should belong to the paritygame class
    (e.g to_dynamic_paritygame) are part of the class. They can be found in the according segment of the
    class definition.  
    Furthermore solution and strategy depend on paritygame, thus some parts are at the end of the file.

    PGBuilder can be found in arrayparitygame.ml
*)

open Tcsbasedata
open Tcsset

(**************************************************************
 *                          NODES                             *
 **************************************************************)
              
(** Type for nodes. Currently  represented as integer value.
    WARNING: May becomes abstract in the future.
*)
type node = int

(** Returns an undefined node. 
    This conforms the integer value of -1.
*)
val nd_undef  : node

(** Creates a string representation of the delivered node.

    @param node node which should be represented as string
    @return string representation
*)
val nd_show : node -> string



(**************************************************************
 *                          NODESET                           *
 **************************************************************)
                        
(* Functions for representing sets of nodes, particularly for successors 
   and predecessors of given nodes *)

(** Type for nodesets.

    @see <https://github.com/tcsprojects/tcslib/blob/master/src/data/tcsset.ml> Treeset of TCSSet
*)
type nodeset 

(** Checks if the given nodeset is empty.

    @param nodeset set to be checked
    @return if nodeset is empty
*)
val ns_isEmpty : nodeset -> bool

(** Checks if the given node is a member of the given nodeset.

    @param node node to be checked
    @param nodeset set to check if node is included
    @return if node is included
*)
val ns_elem    : node -> nodeset -> bool

(** Compares two nodes.

    @param node node n_one to compare
    @param node node n_two to compare with
    @return -1 if n_one < n_two, 0 if n_one = n_two, 1 if n_one > n_two
*)
val ns_nodeCompare : node -> node -> int

(** Compares two nodesets.

    @param nodeset nodeset ns_one to compare
    @param nodeset nodeset ns_two to compare with
    @return -1 if ns_one < ns_two, 0 if ns_one = ns_two, 1 if ns_one > ns_two
*)
val ns_compare : nodeset -> nodeset -> int

(** Constructor for empty nodeset.

    @return empty nodeset
*)
val ns_empty   : nodeset

(** Creates nodeset out of nodelist.

   @param nodelist list of nodes from which set should be created
   @return set of nodes from node list
*)
val ns_make    : node list -> nodeset
                                
(** Returns the number of nodes in a nodeset, e.g. the size.

    @param nodeset nodeset which size should be calculated
    @return size of nodeset
*)
val ns_size    : nodeset -> int

                              
(********** ITERATOR FUNCTIONS **********)
(** Fold nodeset.
 *)                             
val ns_fold    : ('a -> node -> 'a) -> 'a -> nodeset -> 'a
                                                          
(** Iterate nodeset.
 *)
val ns_iter    : (node -> unit) -> nodeset -> unit
                                                
(** Map nodeset.
 *)
val ns_map     : (node -> node) -> nodeset -> nodeset
                                                
(** Filter nodeset via filter function
    
    @param (node -> bool) filter funciton
    @param nodeset nodeset to be filtered
    @retrun filtered nodeset
 *)
val ns_filter  : (node -> bool) -> nodeset -> nodeset

                                                
(********** FINDING ELEMENTS **********)
(** Checks if via specified node does exist.

    @param (node -> bool) specifier
    @param nodeset nodeset to be checked
    @return if node with specification exists
 *)
val ns_exists  : (node -> bool) -> nodeset -> bool
                                                
(** Checks if specification holds for all nodes.

    @param (node -> bool) specifier
    @param nodeset nodeset to be checked
    @return if specification holds for all nodes
 *)
val ns_forall  : (node -> bool) -> nodeset -> bool
                                                
(** Finds and returns specified node option.

    @param (node -> bool) specifier
    @param nodeset nodeset to be searched
    @return if found Some node if not None
 *)
val ns_find    : (node -> bool) -> nodeset -> node
                                                
(** Returns maximum node.
    The maximum is defined via given comparator function.

    @param nodeset nodeset to be searched
    @param (node -> node -> bool) comparator function ( true node one is smaller, false node one is bigger ).
    @return maximum node for comparator
 *)
val ns_max     : nodeset -> (node -> node -> bool) -> node

(** Returns a randomly chosen element from a node set.
    
    @param nodeset nodeset to get random node from
    @return random node
 *)
val ns_some    : nodeset -> node

(** Returns the smallest (by name) node in a nodeset.

    @param nodeset nodeset to get smallest node from
    @return smallest node by name
 *)
val ns_first   : nodeset -> node

(** Returns greatest (by name) node in a nodeset.

    @param nodeset nodeset to get greatest node from
    @param greatest node by name
*)
val ns_last    : nodeset -> node 

(** Add node to nodeset.

    @param node node to add
    @param nodeset nodeset to add to
    @return extended nodeset
 *)

(********** MODIFICATION **********)                        
val ns_add     : node -> nodeset -> nodeset

(** Delete node from nodeset.

    @param node node to be deleted
    @param nodeset nodeset to remove node from
    @return narrowed nodeset
 *)
val ns_del     : node -> nodeset -> nodeset

(** Unifies two nodesets.

    @param nodeset nodeset one to be unified
    @param nodeset nodeset two to be unified
    @return unified nodeset from nodeset one and nodeset two
 *)
val ns_union   : nodeset -> nodeset -> nodeset


(** Extract a list of nodes from a nodeset.

    @param nodeset nodeset to extract nodes as list from
    @return node list from nodeset 
 *)
val ns_nodes   : nodeset -> node list



                                 
(**************************************************************
 *                     NODESET STRUCTURE                      *
 **************************************************************)
(** A type and data structure for a set of game nodes. 
*)
module NodeSet : sig
    type elt = int
    type t
    val empty : t
    val is_empty : t -> bool
    val mem : elt -> t -> bool
    val add : elt -> t -> t
    val singleton : elt -> t
    val remove : elt -> t -> t
    val union : t -> t -> t
    val inter : t -> t -> t
    val diff : t -> t -> t
    val compare : t -> t -> int
    val equal : t -> t -> bool
    val subset : t -> t -> bool
    val iter : (elt -> unit) -> t -> unit
    val fold : (elt -> 'a -> 'a) -> t -> 'a -> 'a
    val for_all : (elt -> bool) -> t -> bool
    val exists : (elt -> bool) -> t -> bool
    val filter : (elt -> bool) -> t -> t
    val partition : (elt -> bool) -> t -> t * t
    val cardinal : t -> int
    val elements : t -> elt list
    val min_elt : t -> elt
    val max_elt : t -> elt
    val choose : t -> elt
    val split : elt -> t -> t * bool * t
end



                   
(**************************************************************
 *                      PLAYER / PRIORITY                     *
 **************************************************************)
(** Type of player. Currently represented as an integer value.
    
    WARNING: This type may become abstract in the future.
*)
type player

(** Type of priority of a node. Currently represented as an integer value.
    This type may become abstract in the future.
*)
type priority = int

                  
(********** PLAYER FUNCTIONS **********)
(** Player even. This player conforms the integer value 0.

    @return player even.
*)
val plr_Even  : player

(** Player odd. This player conforms the integer value 1.

    @return player odd
*)
val plr_Odd   : player

(** Undefined player. This player conforms the integer value -1.

    @return undefined player
*)
val plr_undef : player

(** Returns a random player.

    @return player even or player odd
*)
val plr_random : unit -> player

(** Returns the opponent player.

    @param player delivered player
    @return player odd if player even was delivered. player even, if player odd was delivered.
*)
val plr_opponent : player -> player

(** Returns the player which benefits from the given priority.
    Is the priority even, player even benefits. Is the priority odd, player odd benefits.

    @param priority priority to check for
    @return player which benefits from delivered priority
*)
val plr_benefits : priority -> player

(** Returns a string representation of the player.

    @param player player to be shown
    @return string representation of given player
*)
val plr_show : player -> string

(** Applies function to both players.

    @param f function to be applied to players
*)
val plr_iterate : (player -> unit) -> unit


(********** PRIORITY FUNCTIONS **********)
(** Checks if a given priority is good for a given player.

    @param priority priority to be checked with player
    @param player player to be checked with priority
    @return true, if priority is good for player. false, if priority is not good for player
*)
val prio_good_for_player : priority -> player -> bool

(** Checks if a priority is odd.

    @param priority priority to be checked
    @return if priority is odd
*)
val odd: priority -> bool

(** Checks if a priority is even.

    @param priority priority to be checked
    @return if priority is even
*)
val even: priority -> bool




(**************************************************************
 *                        NODE ORDERING                       *
 **************************************************************)
(** Type of a paritygame ordering. 
    This is a function, which specifies a comparison for two nodes
    to create an ordering.
*)
type pg_ordering  = node * priority * player * nodeset -> node * priority * player * nodeset -> int
                                                                                                  
(** Returns reward of given priority for given player. 
    
    @param player player to check for reward
    @param priority priority to check for
    @return negative (priority x -1) if bad for player, priority if good for player
*)
val reward            : player -> priority -> priority

(** Returns pg_ordering by reward for given player.

    @param player player to get reward-pg_ordering for
    @return reward-pg_ordering for given player
 *)
val ord_rew_for       : player -> pg_ordering

(** Returns pg_ordering by priorities.

    @return pg_ordering by priorities.
 *)
val ord_prio          : pg_ordering

(** Makes given pg_ordering total. Uses compare of Tcsset for former equal nodes.

    @param pg_ordering pg_ordering to make total
    @return total order based on pg_ordering and compare
 *)
val ord_total_by      : pg_ordering -> pg_ordering



                                         

(**************************************************************
 *                        SOLUTION                            *
 **************************************************************)
(** Type of a solution for a paritygame.
    
    WARNING: May becomes abstract in the future.
*)
type solution = player array

(* sol_create and sol_init below paritygame class (because of dependency) *)
(** Creates solution from size of game.
    Works like solution create method.

     @param int size of game
     @return solution 
 *)
val sol_make   : int -> solution         

(** Get the winner of a node according to a 
    solution.

    @param solution solution to determine winner
    @param node node to check for winner
    @return winning player
 *)       
val sol_get    : solution -> node -> player
                                       
(** Set the winner of a node in a solution.

    @param solution solution to change winner for node in
    @param node node to change winner for
    @param player new winner for node
 *)
val sol_set    : solution -> node -> player -> unit

(** Iterate over all nodes with their winners
    in a solution.

    @param (node -> player -> unit) iteration functoin
    @param solution solution to iterate
 *)
val sol_iter   : (node -> player -> unit) -> solution -> unit 

(** For solution testing.
 *)
val sol_number_solved : solution -> int
                                      
(** Returns solution as string.

    @param solution solution to format
    @return string representation of solution
 *)
val format_solution : solution -> string




(***************************************************************
 *                        STRATEGY                             *
 ***************************************************************)                                   
(* create positional strategies for a parity game
 *
 * A value of type strategy is essentially a map of type node -> node that represents positional strategies for both players.
 * The player for whom a decision v -> u is included in the strategy is implicitly given by the owner of node v in the underlying parity game.
 * Warning: a strategy does not remember its underlying parity game. Hence, a strategy that was created for one game can be used for another game,
 * but this can not only obviously lead to wrong computations but also to runtime errors.
 *)
                                    
(** Type of a strategy.

    WARNING: May becomes abstract in the future.
*)
type strategy = node array
                     
(* str_create and str_init below paritygame class (because of dependency) *)
(** Same as str_create, but only gets to know
    the size of the paritygame.

    @param int size of paritygame
    @return strategy for paritygame
 *)
val str_make   : int -> strategy                              

(** Get decision for a node based on strategy.

    @param strategy strategy to check for decision
    @param node node to get decision for
    @param successor of node based on strategy
 *)
val str_get    : strategy -> node -> node

(** Records the strategy decision based node -> node parameters.

    @param strategy strategy to record decision for
    @param node predecessor
    @param node successor 
 *)
val str_set    : strategy -> node -> node -> unit

(** Iterate over all nodes and their corresponding successors
    in a strategy.

    @param (node -> node -> unit) function to use for each pair of node + successor
    @param strategy strategy to iterate
 *)
val str_iter   : (node -> node -> unit) -> strategy -> unit

(** Returns string representation of strategy.

    @param strategy strategy to get string for
    @return string representation of strategy
 *)
val format_strategy : strategy -> string



                                    
(***************************************************************
 *                SOLUTION/STRATEGY FUNCTIONS                  *
 ***************************************************************)
(*
val permute_solution: int array -> solution -> solution
val permute_strategy: int array -> int array -> solution -> solution
*)
(** Exception which signals that two two strategies or solutions
    are unmergable.
 *)
exception Unmergable

(** Calling merge_strategies_inplace strat1 strat2 adds all strategy decisions from strat2 to strat1. 
    Throws an Unmergable-Exception if the domain of both strategies is not empty. 
   
    @param strategy strategy one to merge
    @param strategy strategy two to merge
*)
val merge_strategies_inplace : strategy -> strategy -> unit

(** Calling merge_solutions_inplace sol1 sol2 adds all solution informations from sol2 to sol1. 
    Throws an Unmergable-Exception if the domain of both solutions is not empty. 

    @param solution solution one to merge
    @param solution solution two to merge
*)
val merge_solutions_inplace : solution -> solution -> unit

(** Print solution and strategy.

    @param solution solution to print
    @parm strategy strategy to print
 *)
val print_solution_strategy_parsable : solution -> strategy -> unit



                                                                 
(**************************************************************
 *                   PARTIAL PARITYGAME                       *
 **************************************************************)
(** Type for partial_paritygame.
 *)
type partial_paritygame = node * (node -> node Enumerators.enumerator) * (node -> priority * player) * (node -> string option)
                                                                                                         
(** Type for partial solution.
 *)
type partial_solution = node -> player * node option
                                              
(** Type for partial solver.
 *)
type partial_solver = partial_paritygame -> partial_solution



                                              
(**************************************************************
 *                   DYNAMIC PARITYGAME                       *
 **************************************************************)
(** Type for dynamic paritygame.
 *)
type dynamic_paritygame = (priority * player * string option) Tcsgraph.DynamicGraph.dynamic_graph

(** Returns dynamic subgame by strategy

    @param dynamic_paritygame dynamic paritygame to get subgame from
    @param strategy strategy that determines subgame
    @return subgame of dynamic_paritygame
 *)
val dynamic_subgame_by_strategy: dynamic_paritygame -> strategy -> dynamic_paritygame



                                                                     
(***************************************************************
 *                  DECOMPOSITION FUNCTIONS                    *
 ***************************************************************)
(** Type for a strongly-connected-component.
 *)
type scc = int

(** Returns the leaf SCCs reachable from some SCC in scc_list via topology (scc list array).

    @param scc list scc_list to get leaf SCCs from
    @param scc list array topology
    @return leaf SCCs
*)
val sccs_compute_leaves: scc list -> scc list array -> scc list

(** Returns transposed topology.

    @param scc list array topology to transpose
    @return transposed topology
 *)
val sccs_compute_transposed_topology: scc list array -> scc list array

(** Returns string representation of SCCs.

    @param nodeset array SCCs
    @param scc list array topology
    @param scc list roots
    @return string representation
 *)
val show_sccs : nodeset array -> scc list array -> scc list -> string


                                                                 
                                                                     
(**************************************************************
 *                 (VIRTUAL) PARITYGAME                       *
 **************************************************************)
(** Virtual class representing a paritygame. 
    This class can't be constructed as is and  needs to be inherited 
    In this regard the virtual methods need to be overwritten.
*)
class virtual paritygame : object('self)

  (******************** VIRTUAL METHODS ********************)
        
  (********** GENERAL **********)
  (** Returns size of this paritygame. This does not equals the number of nodes.
      Far more it is the size of the node container of the actual implementation
      of this virtual class.

      @return size of paritygame
  *)
  method virtual size : int

  (** Returns a copy of this object. This is a completely new object.

      @return new paritygame object with same specifications
  *)
  method virtual copy : 'self
                          
  (** Sorts this game by the specifications of the given function.

      @param f function for sorting. expects two node specifications and returns int value which is the bigger one.
  *)
  method virtual sort : ((priority * player * nodeset * nodeset * string option) -> (priority * player * nodeset * nodeset * string option) -> int) -> unit

  (** Iterates over the whole paritygame and applies the given function to each node.

      @param f function which will be applied to each node. expects node and node properties as arguments
  *)
  method virtual iterate : (node -> (priority * player * nodeset * nodeset * string option) -> unit) -> unit
                                                                                                          
  (** Iterate over all edges of the paritygame and applies the given function to each edge.

      @param f function to be applied to each edge 
  *)
  method virtual edge_iterate : (node -> node -> unit) -> unit
                                                            
  (** Mapping function. Maps this paritygame with the given function and returns the result as a new game.

      @param f function to map on the current paritygame
      @return new paritygame from mapping f on this
  *)
  method virtual map : (node -> (priority * player * nodeset * nodeset * string option) ->  (priority * player * nodeset * nodeset * string option)) -> 'self

  (** Mapping function. Maps this paritygame with the given function and returns the result as an a'array.

      @param f function to map on the current paritygame
      @return array with mapped results.
  *)                                                                                                                                                        
  method virtual map2 : (node -> (priority * player * nodeset * nodeset * string option) -> 'a) -> 'a array
                                                                                                      

  (********** GETTERS **********)                                                        
  (** Gets node at the given position in container.

      @param int position of wanted node
      @return node if it exists
  *)
  method virtual get_node : int -> (priority * player * nodeset * nodeset * string option)

  (** Gets priority of given node.

      @param node node which priority is wanted
      @return priority of given node 
  *)
  method virtual get_priority : node -> priority
                                          
  (** Gets owner of given node. Owner means the  player which is allowed to choose on this node.

      @param node node which owner is wanted
      @return owner of this node
  *)
  method virtual get_owner : node -> player

  (** Gets sucessors of given node.

      @param node node which sucessors are wanted
      @return set of sucessors of given node
  *)
  method virtual get_successors : node -> nodeset
                                            
  (** Gets predecessors of given node.

      @param node node which predecessors are wanted
      @return set of predecessors of given node
  *)
  method virtual get_predecessors : node -> nodeset
                                              
  (** Gets description of given node as string option.

      @param node node which descr is wanted
      @return description of given node as string option
  *)
  method virtual get_desc : node -> string option
                                           
  (** Gets description of given node as string.

      @param node node which desc is wanted
      @return description of given node as string
  *)
  method virtual get_desc' : node -> string

  (** Gets node from given description as string option.

      @param stringopt description to look for
      @return node with looked for descr
  *)
  method virtual find_desc : string option -> node
                                 
  (** Checks if the given node is defined. Means if it exists in this paritygame.

      @param node node to be checked
      @return if node is defined
  *)
  method virtual is_defined : node -> bool

  (** Formats game. This means it creates a string representation of this game.

      @return string representation of this game
  *)
  method virtual format_game : string
                                 

  (********** SETTERS **********)
  (** Sets given node at the given position in container of paritygame.

      @param int position where node should be positioned
      @param node node to be set
  *)
  method virtual set_node' : int -> (priority * player * nodeset * nodeset * string option) -> unit

  (** Sets node at given position with given properties.
      Parameters are typical node properties.
  *)
  method virtual set_node : int -> priority -> player -> nodeset -> nodeset -> string option -> unit
                                                                                                  
  (** Sets priority for given node.

      @param node node which priority should be set
      @param priorirty priority to be set to given node
  *)
  method virtual set_priority : node -> priority -> unit

  (** Sets owner for given node. Owener means the player which is allowed to choose on this node.

      @param node node which owner should be set
      @param owner player which should be owner of this node
  *)
  method virtual set_owner : node -> player -> unit

  (** Sets description for given node from string option.

      @param node node which desc should be set
      @param stringopt descr for given node
  *)
  method virtual set_desc : node -> string option -> unit

  (** Sets description for given node from string.

      @param node node which descr should be set
      @param string description for given node
  *)
  method virtual set_desc' : node -> string -> unit

  (** Adds edge between two nodes.

      @param node predecessor node
      @param node sucessor node
  *)
  method virtual add_edge : node -> node -> unit

  (** Deletes existing edge between two nodes.

      @param node predecessor node
      @param node sucessor node
  *)
  method virtual del_edge : node -> node -> unit

  (** Removes all nodes from this game that are specified in the given list.

      @param nodeset set of nodes which should be removed.
  *)
  method virtual remove_nodes : nodeset -> unit

  (** Removes all edges of this game that are specified in the given list. Edges are represented as (predecessor * sucessor) in the list.

      @param list list of edges to be removed.
  *)
  method virtual remove_edges : (node * node) list -> unit
                                                        

  (********** SUBGAME **********)                                               
  (** Creates a subgame from specified edges. This means the subgame includes all nodes connected to the
      edges specified by the given function.

      @param f function to specify edges
      @return subgame created by specified edges
  *)
  method virtual subgame_by_edge_pred : (node -> node -> bool) -> 'self

  (** Creates a subgame from specified nodes. This means the subgame includes all nodes specified by the given function.

      @param f function to specify nodes
      @return subgame created by specified nodes
  *)
  method virtual subgame_by_node_pred : (node -> bool) -> 'self

  (** Create subgame induced and ordered by the nodes list.

      @param nodeset list to create subgame by
      @return subgame created by nodelist
  *)
  method virtual subgame_by_list : nodeset -> 'self

  (** Creates subgame by node filter.

      @param f node filter
  *)
  method virtual subgame_by_node_filter : (node -> bool) -> 'self * (node -> node) * (node -> node)


  (******************** NON-VIRTUAL METHODS ********************)

  (********** GENERAL **********)
  (** Prints game on STDOUT s.t. It could be parsed again. 
   *)
  method print : unit

  (** Prints dotty representation of game with solution and strategy
      into out channel.
  
      @param solution 
      @param strategy 
  *) 
  method to_dotty : solution -> strategy -> out_channel -> unit

  (** Creates dotty file from game with solution and strategy.

      @param solution
      @param strategy
      @param string filename
  *)
  method to_dotty_file : solution -> strategy -> string -> unit 


  (********** GETTERS **********)
  (** Returns count of actual existing nodes in this paritygame.

      @return amount of nodes
  *)                                    
  method node_count : int

  (** Returns count of actual existing edges in this paritygame.

      @return amount of edges
  *)
  method edge_count : int

  (** Gets the maximum node for the given pg_ordering.

      @param pg_ordering pg_ordering which determines the max node
      @return max node for given pg_ordering
  *)
  method get_max : pg_ordering -> node

  (** Gets the minimum node for the given pg_ordering.

      @param pg_ordering pg_ordering which determines the min node
      @return min node for given pg_ordering
  *)
  method get_min : pg_ordering -> node

  (** Gets node with maximum priority in this game.

      @return node with maximum priority
  *)
  method get_max_prio_node  : node

  (** Gets the node with the maximum reward for the given player.

      @param player player to get maximum reward node for
      @return maximum reward node for the given player.
  *)
  method get_max_rew_node_for : player -> node

  (** Gets maximum priority occurring in this game.

      @return maximum priority of this game
  *)
  method get_max_prio : priority

  (** Gets the minimum priority occurring in this game.

      @return minimum priority of this game
  *)
  method get_min_prio : priority

  (** Gets the maximum priority for the given player. Means the node with maximum priority that the player benefits from.

      @param player player to get maximum benefit node for
      @return priority of maximum benifit
  *)
  method get_max_prio_for : player -> priority

  (** Gets index of the game. This means the range of priorities.

      @return index of this game
  *)
  method get_index : int

  (** Gets a list of all nodes with same priority as the given one.

      @param priority priority to find nodes with same priority
      @return list of nodes with priority same as the given one
  *)
  method get_prio_nodes : priority -> nodeset

  (** Gets a list of the priorities occurring in this game from the selected ones.

      @param f function which determines which priorities are selected
      @return list of priorities which are selected and occur in this game
  *)
  method get_selected_priorities : (priority -> bool) -> priority list

  (** Gets a list of all priorities occurring in this game.

      @return list of all priorities
  *)
  method  get_priorities : priority list

  (** Returns string representation of game.
   *)
  method to_string : string

  
  (********** NODE COLLECTION  **********)
  (** Returns set of nodes determined by (node -> priority * player * nodeset * nodeset * string option -> bool).

      @param (node -> priority * player * nodeset * nodeset * string option -> bool) function to determine nodes
      @return set of collected nodes
   *)
  method collect_nodes : (node -> priority * player * nodeset * nodeset * string option -> bool) -> nodeset

  (** Returns set of nodes by priority.

      @param (priority -> bool) function to determine which priority should be returned
      @return set of nodes with specified priority
   *)
  method collect_nodes_by_prio : (priority -> bool) -> nodeset

  (** Returns two lists: The first one contains all nodes v for which f v is true. 
      The other one all those for which it is false. 

      @param (player -> bool) function to determine which nodes belong to this player
      @return pair of sets. see above 
  *)
  method collect_nodes_by_owner : (player -> bool) -> nodeset * nodeset

  (** Returns all nodes with greatest priority 

      @return set of nodes with max prio
  *)
  method collect_max_prio_nodes : nodeset

  (** Collects all nodes with maximum parity.

      @return set of nodes with maximum parity.
   *)
  method collect_max_parity_nodes : nodeset


  (********** SUBGAME **********)
  (** Creates a subgame from a given strategy. This means the subgame includes all nodes specified by the given strategy.

      @param strategy strategy to specify nodes
      @return subgame specified by given strategy
  *)
  method subgame_by_strat : strategy -> 'self

  (** Creates a subgame from strategy + player. This means the subgame includes all nodes specified by the given strategy
      or owned by the opponent player of the given player.

      @param strategy strategy to specify nodes
      @param player player which opponents nodes will be included
      @return subgame specified by given strategy and player
  *)
  method subgame_by_strat_pl : strategy -> player -> 'self
                                                                                                                                 

  (********** DOMINION **********)
  method set_closed: nodeset -> player -> bool
  method set_dominion: ('self -> solution * strategy) -> nodeset -> player -> strategy option

                                                                                       
  (********** DECOMPOSITION **********)
  (** Decomposes the game into its SCCs.
      It returns a tuple (<sccs>, <sccindex>, <topology>, <roots>) where
        
        @param nodeset array  is an array mapping each SCC to its list of nodes,
        @param scc array  is an array mapping each node to its SCC,
        @param scc list array is an array mapping each SCC to the list of its immediate successing SCCs and
        @param scc list is the list of SCCs having no predecessing SCC.
  *)
  method strongly_connected_components : nodeset array * scc array * scc list array * scc list

  (** Computes connectors for SCCs of game.

      @param nodeset array SCCs
      @param scc array SCC index
      @param scc list array topology
      @param scc list roots
      @return hashtable of connectors
   *)
  method sccs_compute_connectors : nodeset array * scc array * scc list array * scc list -> (scc * scc, (scc * scc) list) Hashtbl.t


  (********** ATTRACTOR CLOSURE **********) 
  (** 
      @param strategy strategy 
      @param player player 
      @param nodeset region 
      @param bool include_region 
      @param (node -> bool) tgraph 
      @param bool deltafilter 
      @param nodeset overwrite_strat 
  *)
  method attr_closure_inplace' : strategy -> player -> nodeset -> bool -> (node -> bool) -> bool -> nodeset

  (** Returns the attractor for the given player and region. 
      Additionally all necessary strategy decisions for player leading 
      into the region are added to strategy

      @param strategy strategy
      @param player player
      @param nodeset region
      @return attractor
  *)
  method attr_closure_inplace : strategy -> player -> nodeset -> nodeset
  method attractor_closure_inplace_sol_strat : (node -> bool) -> solution -> strategy -> nodeset -> nodeset -> (nodeset * nodeset)

                                                                                                                 
  (********** PARTIAL PARITYGAME **********)
  (** Induces partial paritygame by startnode.

      @param node start node
      @return partial paritygame
  *)
  method induce_partialparitygame : node -> partial_paritygame

  (** Induces partial paritygame with counter by startnode.

      @param node startnode
      @return pair of counter and partial paritygame
   *)
  method induce_counting_partialparitygame : node -> int ref * partial_paritygame

  method partially_solve_dominion : node -> partial_solver -> solution * strategy
  method partially_solve_game : partial_solver -> solution * strategy

                                                               
  (********** GAME INFORMATION **********)
  method get_player_decision_info : bool * bool
  method is_single_parity_game : priority option

  (** Computes the number of strategies for a player in a game.
      

      @param player player to get amount of strats for
      @param int upper bound on the returned value 
      @return amount of strategies for player (bounded by m)
  *)
  method number_of_strategies : player -> int -> int
  method compute_priority_reach_array : player -> priority array array


  (********** DYNAMIC PARITYGAME **********)
  (** Create dynamic paritygame out of this.

      @return dynamic paritygame corresponding to this
   *)
  method to_dynamic_paritygame : dynamic_paritygame

  (** Create dynamic paritygame out of this determined by strategy.

      @param strategy determines how dynamic paritygame looks
      @return dynamic paritygame determined by strategy
   *)
  method to_dynamic_paritygame_by_strategy : strategy -> dynamic_paritygame
 

  (********** MODAL LOGIC **********)
  (** Returns the set of all nodes in this pg that have at least one successor in nodeset.

      @param Nodeset.t nodeset to look for successor
      @return set of all nodes with one or more successors in nodeset
  *)
  method get_diamonds : NodeSet.t -> NodeSet.t

  (** Returns set of all nodes in this pg that have all successors in nodeset.

      @param NodeSet.t nodeset to look for all successors
      @return set of nodes with all successors in nodeset
   *)
  method get_boxes     : NodeSet.t -> NodeSet.t                                
end



                             
(**************************************************************
 *                     SOLUTION PART 2                        *
 **************************************************************)
(** Creates solution for game.
    Initially, every node is won by player_undef.

    @param game game to create solution for (determines size)
    @return solution for game
 *)
val  sol_create : paritygame -> solution

(** Create solution for game,
    Initially filled with values determined by (node -> player).

    @param game game to create solution for
    @param (node -> player) function to determine values for solution
    @return initialized solution
 *)
val  sol_init   : paritygame -> (node -> player) -> solution


                                                      

(***************************************************************
 *                      STRATEGY PART 2                        *
 ***************************************************************)                                   
(** Creates strategy for paritygame.
    Initially, every node maps to nd_undef.

    @param paritygame paritygame to create strategy for
    @return strategy for paritygame
 *)
val str_create : paritygame -> strategy

(** Create strategy initially filled with decisions 
    according to (node -> node) function.

    @param paritygame paritygame to create strategy for
    @param (node -> node) decisions for each node
    @return initialized strategy
 *)
val str_init   : paritygame -> (node -> node) -> strategy


                                                   
                                                   
(**************************************************************
 *                       GLOBAL SOLVER                        *
 **************************************************************)
(** Solver type.
    A type for algorithms that solve a paritygame.
 *)
type global_solver = paritygame -> solution * strategy






